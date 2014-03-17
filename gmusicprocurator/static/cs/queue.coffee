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

class gmp.Queue extends gmp.Playlist
  ###
  The play queue.
  ###
  constructor: (data, options) ->
    data ||= {}
    data.id = gmp.QUEUE_ID
    data.name = 'Play Queue'
    data.current_track = 0
    super(data, options)

  current: ->
    ###
    Retrieves the currently playing track.

    :rtype: gmp.PlaylistEntry
    ###
    tracks = @get('tracks')
    return null if tracks.length == 0
    return tracks.at(@get('current_track'))

  previous: ->
    ###
    Sets the current track to the previous one.

    :rtype: gmp.PlaylistEntry or :data:`null`
    ###
    @seek(@get('current_track') - 1)

  next: ->
    ###
    Advances the queue to the next track.

    :rtype: gmp.PlaylistEntry or :data:`null`
    ###
    @seek(@get('current_track') + 1)

  seek: (idx) ->
    ###
    Retrieves a specific entry in the playlist and set it as the current track.

    :type idx: :class:`Number` (int)
    :rtype: gmp.PlaylistEntry or :data:`null`
    ###
    return null if idx < 0 or idx >= @get('tracks').length
    @set('current_track', idx)
    return @current()

  insert_entry_after_current: (entry) ->
    ###
    Inserts a playlist entry after the current track.

    :rtype: :coffee:class:`Number` (int)
    :returns: The index of the playlist entry
    ###
    track_ct = @get('tracks').length
    # empty list
    if track_ct == 0
      @add_entries(entry)
      return 0
    entry_idx = @get('current_track') + 1
    @add(entry, {at: entry_idx})
    return entry_idx

  add_playlist: (playlist) ->
    ###
    Adds a non-queue playlist to the queue.

    :type playlist: :coffee:class:`playlist::gmp.Playlist`
                    (not :coffee:class:`queue::gmp.Queue`)
    ###
    return unless playlist?
    return if playlist instanceof gmp.Queue
    @add_entries(playlist.get('tracks').models)

class gmp.QueueView extends gmp.PlaylistView
  constructor: (options) ->
    super(options)
    @model.on('change:current_track', @on_change_track)

  play_track: (e) ->
    e.stopImmediatePropagation()
    return unless @model.seek($(e.target).parent().data('idx'))

  on_change_track: (model, value, options) =>
    entry = model.get('tracks').at(value)
    icon = @$el.find("tr[data-entry-id=\"#{entry.get('id')}\"] .albumart .fa")
    @_play_track(entry.get('track'), icon)
