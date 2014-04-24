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

  shuffle_idx: (current, size) ->
    idx = current
    if size > 1
      while idx == current
        idx = Math.floor(Math.random() * size)
    return idx

  previous: (play_mode) ->
    ###
    Sets the current track to the previous one.

    :rtype: gmp.PlaylistEntry or :js:data:`null`
    ###
    current_track = @get('current_track')
    queue_size = @get('tracks').length
    if play_mode == 'shuffle'
      prev_idx = @shuffle_idx(current_track, queue_size)
    else
      prev_idx = current_track - 1
      if play_mode == 'continuous' and prev_idx < 0
        # In Python/Ruby/Lua/Perl, -1 % n == n - 1.
        # In C/Java/JS, -1 % n == -1.
        prev_idx += queue_size
    @seek(prev_idx)

  next: (play_mode) ->
    ###
    Advances the queue to the next track.

    :rtype: gmp.PlaylistEntry or :js:data:`null`
    ###
    current_track = @get('current_track')
    queue_size = @get('tracks').length
    if play_mode == 'shuffle'
      next_idx = @shuffle_idx(current_track, queue_size)
    else
      next_idx = current_track + 1
      next_idx %= queue_size if play_mode == 'continuous'
    @seek(next_idx)

  seek: (idx, force_change) ->
    ###
    Retrieves a specific entry in the playlist and set it as the current track.

    :type idx: :js:class:`Number` (int)
    :param Boolean force_change: Whether to force a track change if ``idx`` is
                                 the same as ``current_track``.
    :rtype: gmp.PlaylistEntry or :js:data:`null`
    ###
    return null if idx < 0 or idx >= @get('tracks').length
    if @get('current_track') == idx
      @trigger('change:current_track', this, idx, {}) if force_change
    else
      @set('current_track', idx)
    return @current()

  insert_entry_after_current: (entry) ->
    ###
    Inserts a playlist entry after the current track.

    :rtype: :js:class:`Number` (int)
    :returns: The index of the playlist entry
    ###
    track_ct = @get('tracks').length
    # empty list
    if track_ct == 0
      @add_entries(entry)
      return 0
    entry_idx = @get('current_track') + 1
    @add_entries(entry, {at: entry_idx})
    return entry_idx

  add_playlist: (playlist) ->
    ###
    Adds a non-queue playlist to the queue.

    :type playlist: :class:`playlist::gmp.Playlist`
                    (not :class:`queue::gmp.Queue`)
    ###
    return unless playlist?
    return if playlist instanceof gmp.Queue
    @add_entries(playlist.get('tracks').models)

class gmp.QueueView extends gmp.PlaylistView
  constructor: (options) ->
    super(options)
    @model.on('change:current_track', @on_current_track_changed)

  render: ->
    super()
    if gmp.player.is_playing()
      @icon_for_index(@model.get('current_track')).addClass('fa-music')
    return this

  play_track: (e) ->
    e.stopImmediatePropagation()
    idx = $(e.target).parent().data('idx')
    same_track = idx == @model.get('current_track')
    return if same_track and gmp.player.is_playing()
    @model.seek(idx, same_track)

  icon_for_index: (idx) ->
    return @icon_for_entry(@model.get('tracks').at(idx))

  icon_for_entry: (entry) ->
    return @$el.find("tr[data-entry-id=\"#{entry.get('id')}\"] .albumart .fa")

  on_current_track_changed: (model, value) =>
    entry = model.get('tracks').at(value)
    @_play_track(entry.get('track'), @icon_for_entry(entry))
