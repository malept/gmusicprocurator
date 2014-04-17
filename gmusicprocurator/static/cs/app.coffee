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

class gmp.AppView extends Backbone.View
  el: 'main'

  initialize: ->
    gmp.playlists = new gmp.PlaylistCollection

    @listenTo gmp.playlists, 'add', (playlist) ->
      view = new gmp.PlaylistEntryView({model: playlist})
      $('#playlists').append(view.render().el)

    gmp.queue = new gmp.QueueView({model: new gmp.Queue})
    gmp.playlists.add(gmp.queue.model)
    gmp.player = new gmp.PlayerView({model: gmp.queue.model})
    $('body > footer').append(gmp.player.render().el)

####
# Initializer
####

$ ->
  gmp.app = new gmp.AppView
  if location.search.indexOf('offline') == -1
    gmp.playlists.fetch
      success: ->
        $('#playlists-loading').remove()
        gmp.playlist_router = new gmp.PlaylistRouter
        Backbone.history.start()
  else
    $('#playlists-loading').remove()
