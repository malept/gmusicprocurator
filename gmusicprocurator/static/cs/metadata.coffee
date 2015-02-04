# -*- coding: utf-8 -*-
# vim: set ts=2 sts=2 sw=2 :
#
###! Copyright (C) 2015 Mark Lee, under the GPL (version 3+) ###
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

class gmp.Album extends AlpacAudio.TrackList
  urlRoot: '/albums'

  constructor: (data, options) ->
    super(data, options)
    @tracklist = new AlpacAudio.TrackListView(model: this)

  parse: (resp) ->
    resp.tracks = new AlpacAudio.TrackListEntries(resp.tracks)
    return resp

  duration: ->
    ###
    Total duration of the album, in milliseconds.
    ###
    entries = if @get? then @get('tracks') else @tracks
    times = entries.map (entry) -> entry.get('track').get('durationMillis')
    _.reduce(times, (sum, len) -> parseInt(sum) + parseInt(len))

  genres: ->
    ###
    A list of unique genres, generated from track metadata.
    ###
    _.uniq(@get('tracks').map((t) -> t.get('track').get('genre')))


class gmp.Albums extends Backbone.Collection


class gmp.AlbumView extends AlpacAudio.TrackListView
  className: 'scrollable-container'
  id: 'album'
  tagName: 'section'
  template: AlpacAudio.get_template('album', 'album')

  render_data: ->
    data = super()
    data.genres = @model.genres()
    data.tracks.each (track) -> track.set('albumArtRef', data.albumArtRef)
    data.duration = @model.duration()
    return data


class gmp.MetadataRouter extends Backbone.Router
  routes:
    'albums/:id': 'load_album'

  render_album: (album) ->
    if gmp.album_view?
      gmp.album_view.model = album
    else
      gmp.album_view = new gmp.AlbumView(model: album)
    gmp.album_view.renderify('main nav:first', 'after')
    album.tracklist.renderify('#album-metadata', 'after')

  load_album: (id) ->
    gmp.albums ?= new gmp.Albums
    album = gmp.albums.get(id)
    if album
      @render_album(album)
    else
      album = new gmp.Album(id: id)
      gmp.albums.add(album)
      album.fetch(success: => @render_album(album))
