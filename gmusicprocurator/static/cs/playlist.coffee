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
  constructor: (data, options) ->
    data ||= {}
    tracks = if data.tracks? then data.tracks else []
    data.tracks = new gmp.PlaylistEntries(tracks)
    super(data, options)

  add_track: (track) ->
    @add_entries(new gmp.PlaylistEntry({track: track}))

  add_entries: (entry_or_entries) ->
    @get('tracks').add(entry_or_entries)

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

class gmp.PlaylistView extends gmp.SingletonView
  tagName: 'section'
  id: 'playlist'
  className: 'pure-u-4-5'
  template: _.template($('#playlist-tpl').html())
  events:
    'mouseover .albumart span.fa': 'album_mouseover'
    'mouseout .albumart span.fa': 'album_mouseout'
    'click .albumart span.fa-play': 'play_track'
    'click .add-to-queue': 'add_to_queue'

  album_mouseover: (e) ->
    icon = $(e.target)
    return false if icon.hasClass('fa-music') or icon.hasClass('fa-spinner')
    icon.addClass('fa-play')

  album_mouseout: (e) ->
    icon = $(e.target)
    return false if icon.hasClass('fa-music') or icon.hasClass('fa-spinner')
    icon.removeClass('fa-play')

  _play_track: (song, icon) ->
    spin_cls = 'fa-spinner fa-spin'
    @$('.albumart span.fa-music').removeClass('fa-music')
    @$('.albumart span.fa-spinner').removeClass(spin_cls)
    gmp.player.play(song)
    icon.removeClass('fa-play').addClass(spin_cls)
    gmp.player.audio.play_started ->
      icon.removeClass(spin_cls).addClass('fa-music')

  play_track: (e) ->
    icon = $(e.target)
    trow = icon.closest('tr')
    entry_id = trow.data('entry-id')
    song = @model.get('tracks').get(entry_id).get('track')
    @_play_track(song, icon)

  add_to_queue: (e) ->
    gmp.queue.model.add_playlist(@model)

class gmp.PlaylistEntryView extends gmp.View
  tagName: 'li'
  template: _.template($('#playlist-entry-tpl').html())

####
# Routers
####

class gmp.PlaylistRouter extends Backbone.Router
  routes:
    'playlist/:id': 'load_playlist'

  load_playlist: (id) ->
    if id == gmp.QUEUE_ID
      view = gmp.queue
    else
      view = new gmp.PlaylistView({
        model: gmp.playlists.get(id)
      })
    view.renderify('main nav:first', 'after')
    if id == gmp.QUEUE_ID
      view.delegateEvents()
