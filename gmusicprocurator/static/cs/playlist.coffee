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

####
# Routers
####

class gmp.PlaylistRouter extends Backbone.Router
  routes:
    'playlist/:id': 'load_playlist'

  constructor: (options) ->
    super(options)
    @playlists =
      queue: AlpacAudio.queue.render()

  load_playlist: (id) ->
    view = @playlists[id]
    func = 'replace'
    unless view
      view = new AlpacAudio.TrackListView({
        model: AlpacAudio.playlists.get(id)
      })
      @playlists[id] = view
      func = 'renderify'
    view[func]('main nav:first', 'after')
