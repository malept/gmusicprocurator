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
# Models
####

class gmp.AllSongs extends gmp.Playlist
  ###
  Special-cased playlist for "all songs".
  ###
  url: '/playlists/all_songs'

  constructor: (data, options) ->
    data ?= {}
    data.id = 'all_songs'
    data.name = 'Free/Purchased/Uploaded'
    @fetch()
    super(data, options)

  parse: (resp) ->
    resp.tracks = new gmp.PlaylistEntries(resp.tracks)
    return resp
