#!/usr/bin/env python
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

from datetime import datetime
from flask import abort, Response, url_for
from mutagen.mp3 import EasyMP3 as MP3
import requests
from tempfile import NamedTemporaryFile
from xspf import Xspf

from .app import app, music

# Google : Mutagen EasyID3
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


@app.route('/songs/<song_id>')
def get_song(song_id):
    song_info = music.get_track_info(song_id)
    song_url = music.get_stream_url(song_id, app.config['GACCOUNT_DEVICE_ID'])
    response = requests.get(song_url)
    with NamedTemporaryFile() as f:
        f.write(response.content)
        f.flush()
        audio = MP3(f.name)
        for gmf, id3f in METADATA_FIELDS.iteritems():
            if gmf in song_info:
                audio[id3f] = str(song_info[gmf])
        audio.save()
        f.seek(0)
        return Response(open(f.name).read(), mimetype='audio/mpeg')


@app.route('/playlists/<playlist_id>')
def get_playlist(playlist_id):
    playlists = [p for p in music.get_all_user_playlist_contents()
                 if p['id'] == playlist_id]
    if len(playlists) == 0:
        abort(404)
    playlist = playlists[0]
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
    return Response(xspf.toXml(), mimetype='application/xspf+xml')
