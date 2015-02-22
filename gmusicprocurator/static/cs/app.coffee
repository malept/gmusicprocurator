# -*- coding: utf-8 -*-
# vim: set ts=2 sts=2 sw=2 :
#
###! Copyright (C) 2014, 2015 Mark Lee, under the GPL (version 3+) ###
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

class gmp.AppView extends Backbone.View
  el: 'main'

  initialize: ->
    @initialize_player() if @is_player_page()

  initialize_player: ->
    AlpacAudio.playlists = new AlpacAudio.PlaylistCollection

    @listenTo AlpacAudio.playlists, 'add', (playlist) ->
      view = new AlpacAudio.TrackListEntryView({model: playlist})
      $('#playlists').append(view.render().el)

    AlpacAudio.queue = new AlpacAudio.QueueView({model: new AlpacAudio.Queue})
    AlpacAudio.playlists.add(AlpacAudio.queue.model)

    AlpacAudio.tracks = new AlpacAudio.Tracks
    gmp.all_songs = new AlpacAudio.TrackListView({model: new gmp.AllSongs})
    AlpacAudio.playlists.add(gmp.all_songs.model)

    gmp.search_box = new gmp.SearchBox
    $('body > header').append(gmp.search_box.render().el)

    AlpacAudio.player = new AlpacAudio.PlayerView
      model: AlpacAudio.queue.model
      settings: new AlpacAudio.PlayerSettings
    $('body > footer').append(AlpacAudio.player.render().el)

  render: ->
    @render_player() if @is_player_page()

  render_player: ->
    if location.search.indexOf('offline') == -1
      AlpacAudio.playlists.fetch
        remove: false
        success: ->
          $('#playlists-loading').remove()
          gmp.playlist_router = new gmp.PlaylistRouter
          gmp.metadata_router = new gmp.MetadataRouter
          gmp.search_router = new gmp.SearchRouter
          Backbone.history.start()
    else
      $('#playlists-loading').remove()

  is_player_page: -> $('#playlists').length > 0

####
# Initializer
####

$ ->
  gmp.app = new gmp.AppView
  gmp.app.render()
