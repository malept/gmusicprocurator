# -*- coding: utf-8 -*-
# vim: set ts=2 sts=2 sw=2 :
#
###! Copyright (C) 2014 Mark Lee, under the GPL (version 3+) ###
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

####
# Models / Collections
####

class gmp.Playlist extends Backbone.Model
  active: false

  constructor: (data, options) ->
    tracks = data.tracks
    data.tracks = new gmp.PlaylistEntries(tracks)
    super(data, options)

class gmp.PlaylistCollection extends Backbone.Collection
  model: gmp.Playlist

class gmp.PlaylistEntry extends Backbone.Model
  constructor: (data, options) ->
    track = data.track
    data.track = new gmp.Track(track)
    super(data, options)

class gmp.PlaylistEntries extends Backbone.Collection
  model: gmp.PlaylistEntry

class gmp.Track extends Backbone.Model
  constructor: (data, options) ->
    data.id = data.storeId if !!data && !!data.storeId
    super(data, options)

class gmp.Tracks extends Backbone.Collection
  model: gmp.Track

####
# Views
####

class gmp.PlaylistView extends Backbone.View
  tagName: 'section'
  template: _.template($('#playlist-tpl').html())
  events:
    'mouseover .albumart span': 'album_mouseover'
    'mouseout .albumart span': 'album_mouseout'
    'click .albumart span': 'play_track'
  render: ->
    @$el.html(@template(@model.toJSON()))
    return this

  album_mouseover: (e) ->
    $(e.target).addClass('fa-play').css('background-image', '')

  album_mouseout: (e) ->
    aa = $(e.target)
    aa.removeClass('fa-play')
    aa.css('background-image', "url(#{aa.data('art-url')})")

  play_track: (e) ->
    gmp.player.play("/songs/#{$(e.target).data('song-id')}")


class gmp.PlaylistEntryView extends Backbone.View
  tagName: 'li'
  template: _.template($('#playlist-entry-tpl').html())
  events:
    'click a[data-playlist-id]': 'load_playlist'
  render: ->
    @$el.html(@template(@model.toJSON()))
    return this

  load_playlist: (e) ->
    e.preventDefault()
    view = new gmp.PlaylistView({
      model: gmp.playlists.get($(e.target).data('playlist-id'))
    })
    $('#playlist').empty().append(view.render().el)
    return false
