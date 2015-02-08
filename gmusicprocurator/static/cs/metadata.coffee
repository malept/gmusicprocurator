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

class gmp.Metadata extends AlpacAudio.TrackList

  constructor: (data, options) ->
    super(data, options)
    @tracklist = new AlpacAudio.TrackListView(model: this)

  parse: (resp) ->
    tracks_attr = @tracks_attr or 'tracks'
    resp.tracks = new AlpacAudio.TrackListEntries(resp[tracks_attr])
    return resp


class gmp.Album extends gmp.Metadata
  urlRoot: '/albums'

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


class gmp.Artist extends gmp.Metadata
  urlRoot: '/artists'
  tracks_attr: 'topTracks'

  parse: (resp) ->
    resp[@tracks_attr] = ({track: t} for t in resp[@tracks_attr])
    return super(resp)


class gmp.Artists extends Backbone.Collection


class gmp.ArtistView extends AlpacAudio.SingletonView
  className: 'scrollable-container'
  id: 'artist'
  tagName: 'section'
  template: AlpacAudio.get_template('artist', 'artist')


class gmp.MetadataRouter extends Backbone.Router
  routes:
    'albums/:id': 'load_album'
    'artists/:id': 'load_artist'

  render_item: (item, view_attr, view_cls, tracklist_selector) ->
    if gmp[view_attr]?
      gmp[view_attr].model = item
    else
      gmp[view_attr] = new view_cls(model: item)
    gmp[view_attr].renderify('main nav:first', 'after')
    item.tracklist.renderify(tracklist_selector, 'after')

  render_album: (album) =>
    @render_item(album, 'album_view', gmp.AlbumView, '#album-metadata')

  render_artist: (artist) =>
    artist.set('dont_scroll', true)
    @render_item(artist, 'artist_view', gmp.ArtistView, '#related-artists + h4')

  load_item: (id, collection_attr, collection, model, render_item) ->
    gmp[collection_attr] ?= new collection
    item = gmp[collection_attr].get(id)
    if item
      render_item(item)
    else
      item = new model(id: id)
      gmp[collection_attr].add(item)
      item.fetch(success: -> render_item(item))

  load_album: (id) ->
    @load_item(id, 'albums', gmp.Albums, gmp.Album, @render_album)

  load_artist: (id) ->
    @load_item(id, 'artists', gmp.Artists, gmp.Artist, @render_artist)
