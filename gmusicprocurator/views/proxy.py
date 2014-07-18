# -*- coding: utf-8 -*-
#
# Copyright (C) 2014  Mark Lee
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""Flask views for the Google Music proxy."""

from datetime import datetime
from flask import abort, request, Response, url_for
from flask.json import jsonify
from functools import wraps
from io import BytesIO
import requests
from shutil import copyfileobj
from tempfile import NamedTemporaryFile
from werkzeug.exceptions import ServiceUnavailable
from xspf import Xspf

from ..app import app, music
from ..id3 import EasyMP3

HALF_MB = 1024 * 512  # in bytes

JSON_TYPE = 'application/json'
MP3_TYPE = 'audio/mpeg'
XSPF_TYPE = 'application/xspf+xml'

# Mapping: Google : Mutagen EasyID3
METADATA_FIELDS = {
    'artist': 'artist',
    'title': 'title',
    'album': 'album',
    'albumArtist': 'albumartistsort',
    'composer': 'composer',
    'trackNumber': 'tracknumber',
    'discNumber': 'discnumber',
    'genre': 'genre',
    'year': 'date',
    'durationMillis': 'length',
}

if app.config['GMP_EMBED_ALBUM_ART']:
    METADATA_FIELDS['albumArtRef'] = 'albumart'


def online_only(f):
    """
    View decorator to ensure execution only in online mode.

    If ``GMP_OFFLINE_MODE`` is set, a 503 is returned.
    """
    @wraps(f)
    def check_offline_mode(*args, **kwargs):
        if app.config['GMP_OFFLINE_MODE']:
            raise ServiceUnavailable()
        return f(*args, **kwargs)

    return check_offline_mode


def mp3ify(resp):
    """Set MIME Type and Content-Disposition header suitable for MP3s."""
    if resp.mimetype != MP3_TYPE:
        resp.mimetype = MP3_TYPE
    resp.headers.add('Content-Disposition', 'inline', filename='song.mp3')
    return resp


def gmusic_playlist_to_xspf(playlist_id, playlist):
    """
    Convert a playlist from gmusicapi into an XSPF playlist.

    :type playlist: dict
    :return: XSPF (XML), UTF-8 encoded
    :rtype: str
    """
    create_ts = int(playlist['creationTimestamp']) / 1000000.0
    create_iso = datetime.utcfromtimestamp(create_ts).isoformat()
    p_url = url_for('get_playlist', _external=True, playlist_id=playlist_id)
    xspf = Xspf(title=playlist['name'], creator=playlist['ownerName'],
                date=create_iso, location=p_url)
    for track in playlist['tracks']:
        if 'track' not in track:
            continue
        tmd = track['track']
        url = url_for('get_song', _external=True, song_id=tmd['storeId'])
        metadata = {
            'location': url,
            'title': tmd['title'],
            'creator': tmd['artist'],
            'album': tmd['album'],
            'trackNum': str(tmd['trackNumber']),
            'duration': tmd['durationMillis'],
        }
        album_art = tmd.get('albumArtRef', [])
        if album_art:
            metadata['image'] = album_art[0]['url']
        xspf.add_track(metadata)
    return xspf.toXml()


def add_id3_tags_to_mp3(song_id, input_data):
    """
    Attach ID3 tags to MP3 data.

    :param str song_id: The Google Music song ID.
    :param io.BytesIO input_data: The MP3 data.
    :return: the modified MP3 data
    :rtype: :class:`io.BytesIO`
    """
    song_info = music.get_track_info(song_id)
    output = BytesIO()
    # We have to write the MP3 data to a temporary file so mutagen can add
    # metadata to it.
    with NamedTemporaryFile() as f:
        f.write(input_data.getvalue())
        f.flush()
        audio = EasyMP3(f.name)
        for gmf, id3f in METADATA_FIELDS.iteritems():
            if gmf in song_info:
                if isinstance(song_info[gmf], basestring):
                    audio[id3f] = song_info[gmf]
                elif isinstance(song_info[gmf], list):
                    # take the first value, see what it is
                    val = song_info[gmf][0]
                    if isinstance(val, basestring):
                        audio[id3f] = val
                    elif isinstance(val, dict) and 'url' in val:
                        # e.g., albumArtRef
                        audio[id3f] = val['url']
                    else:
                        audio[id3f] = str(val)
                else:
                    audio[id3f] = str(song_info[gmf])
        audio.save()
        copyfileobj(open(f.name, 'rb'), output)
    return output


@app.route('/songs/<song_id>/info')
@online_only
def get_song_info(song_id):
    """Retrieve the song metadata from the Google Music API."""
    return jsonify(music.get_track_info(song_id))


@app.route('/songs/<song_id>')
@online_only
def get_song(song_id):
    """Retrieve the MP3 for a given ID."""
    if song_id == 'undefined':
        # This occurs when the web UI sends a nonexistent song ID.
        abort(404)
    song_url = music.get_stream_url(song_id, app.config['GACCOUNT_DEVICE_ID'])
    if app.config['GMP_SONG_FILTERS']:
        response = requests.get(song_url)
        data = BytesIO(response.content)
        for song_filter in app.config['GMP_SONG_FILTERS']:
            if callable(song_filter):
                data = song_filter(song_id, data)
            else:
                data = globals()[song_filter](song_id, data)
        return mp3ify(Response(data.getvalue()))
    else:
        response = requests.get(song_url, stream=True)
        return mp3ify(Response(response.iter_content(chunk_size=HALF_MB)))


@app.route('/playlists/<playlist_id>')
@online_only
def get_playlist(playlist_id):
    """Retrieve the metadata for a given playlist."""
    # 2014-02-25: At the time of this writing, this idiom is the only way to
    # get a single playlist via the API.
    playlists = [p for p in music.get_all_user_playlist_contents()
                 if p['id'] == playlist_id]
    if len(playlists) == 0:
        abort(404)

    playlist = playlists[0]

    resp_type = request.accept_mimetypes.best_match([XSPF_TYPE, JSON_TYPE])
    # Return JSON playlist only if explicitly requested.
    if resp_type == JSON_TYPE:
        return jsonify(playlist)

    # Generate XSPF playlist, otherwise.
    return Response(gmusic_playlist_to_xspf(playlist_id, playlist),
                    mimetype=XSPF_TYPE)


@app.route('/playlists')
@online_only
def get_playlists():
    """Retrieve all of the logged in user's playlists."""
    gmusic_playlists = music.get_all_user_playlist_contents()

    resp_type = request.accept_mimetypes.best_match([XSPF_TYPE, JSON_TYPE])
    # Return JSON playlist only if explicitly requested.
    if resp_type == JSON_TYPE:
        return jsonify({
            'playlists': gmusic_playlists,
        })

    # Generate XSPF playlist, otherwise.
    xspf = Xspf(title='Playlists',
                location=url_for('get_playlists', _external=True))

    for playlist in gmusic_playlists:
        if playlist['deleted']:
            continue
        xspf.add_track({
            'location': url_for('get_playlist', _external=True,
                                playlist_id=playlist['id']),
            'title': playlist['name'],
            'creator': playlist['ownerName'],
        })

    return Response(xspf.toXml(), mimetype=XSPF_TYPE)
