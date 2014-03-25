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

gmp.human_readable_time = (seconds) ->
  ###
  Converts seconds to MM:SS.
  ###
  minutes = (seconds / 60).toFixed(0)
  remainder = (seconds % 60).toFixed(0)
  remainder = "0#{remainder}" if remainder < 10
  return "#{minutes}:#{remainder}"

gmp.load_audio_backend = ->
  backends = [
    gmp.HTML5Audio
    gmp.AuroraAudio
  ]
  for backend_cls in backends
    backend = new backend_cls
    if backend.audio_playable() and backend.mp3_playable()
      return backend
  return null

class gmp.NowPlayingView extends gmp.SingletonView
  tagName: 'span'
  id: 'now-playing'
  template: gmp.get_template('now-playing')


class gmp.PlayerView extends Backbone.View
  tagName: 'section'
  id: 'player'
  template: gmp.get_template('player')
  events:
    'click .play-pause': 'play_pause'
    'click .stop': 'stop'
    'click .rewind': 'rewind'
    'click .forward': 'forward'
    'click .previous': 'previous_track'
    'click .next': 'next_track'
    'click .volume-control': 'toggle_volume_control_widget'
    'change .volume-control-widget': 'update_volume'
    'click #track-position': 'update_position_from_progress'
  render: ->
    @$el.html(@template())

    @$play_pause = @$el.find('.play-pause').children('span')
    @$track_position = @$el.children('#track-position')

    @audio = gmp.load_audio_backend()
    return this unless @audio

    # For some reason, can't transform these into view-based events
    @audio.pause =>
      @$play_pause.removeClass('fa-pause').addClass('fa-play')
    @audio.play =>
      @$play_pause.removeClass('fa-play').addClass('fa-pause')
    @audio.durationchange =>
      @$track_position.attr('max', @audio.duration())
    @audio.timeupdate =>
      @$track_position.val(@audio.currentTime())
      cur_pos = gmp.human_readable_time(@audio.currentTime())
      total = gmp.human_readable_time(@audio.duration())
      @$track_position.attr('title', "#{cur_pos} / #{total}")

    @$volume_icon = @$el.find('.volume-control').children('span')
    @$volume_widget = @$el.find('.volume-control-widget')
    @$volume_widget.val(50).change()

    return this

  play: (metadata, url = null) ->
    url = gmp.song_url(metadata) unless url
    if @audio?.audio_playable()
      if @audio.mp3_playable()
        @audio.load(url)
        tview = new gmp.NowPlayingView({model: metadata})
        tview.renderify('#player > nav', 'prepend')
      else
        window.alert 'You cannot play MP3s natively. Sorry.'
    else
      window.alert 'Cannot play HTML5 audio. Sorry.'

  ####
  # Event Handlers
  ####

  play_pause: ->
    @audio.toggle_playback()

  stop: ->
    return false unless @audio.play_started()
    @audio.stop()

  rewind: ->
    return false unless @audio.play_started()
    @audio.seek(-5)

  forward: ->
    return false unless @audio.play_started()
    @audio.seek(5)

  _select_track: (func_name) ->
    entry = @model[func_name]()
    return unless entry?
    track = entry.get('track')
    @play(track)

  previous_track: ->
    @_select_track('previous')

  next_track: ->
    @_select_track('next')

  toggle_volume_control_widget: ->
    @$volume_widget.toggleClass('invisible')

  update_volume: (e) =>
    volume = $(e.target).val() / 100
    @audio.volume(volume)
    @$volume_icon.removeClass('fa-volume-off fa-volume-down fa-volume-up')
    if volume > 0.5
      volume_cls = 'fa-volume-up'
    else if volume > 0
      volume_cls = 'fa-volume-down'
    else
      volume_cls = 'fa-volume-off'
    @$volume_icon.addClass(volume_cls)

  update_position_from_progress: (e) =>
    return false unless @audio.play_started()
    $tgt = $(e.target)
    # see http://bugs.jquery.com/ticket/8523#comment:12
    offset = e.offsetX or (e.clientX - $tgt.offset().left)
    @audio.currentTime((offset / $tgt.width()) * @audio.duration())

  is_playing: ->
    return @audio.is_playing()
