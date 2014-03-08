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

#
# Note: only does SSSS -> MM:SS
#
gmp.human_readable_time = (seconds) ->
  minutes = (seconds / 60).toFixed(0)
  remainder = (seconds % 60).toFixed(0)
  remainder = "0#{remainder}" if remainder < 10
  return "#{minutes}:#{remainder}"

class gmp.HTML5Audio
  constructor: ->
    @player = new Audio()
    @$player = $(@player)
    @$player.attr('autoplay', 'autoplay')

    create_evt_func = (name, args...) =>
      return (callback = null) =>
        if !!callback
          @$player.on name, callback
        else if !!@player[name]
          @player[name](args...)
        else
          @$player.trigger(name, args)
    for n in ['play', 'pause', 'durationchange', 'timeupdate']
      @[n] = create_evt_func(n)

    create_prop_func = (name) =>
      return (val = null) ->
        if val is null
          return @player[name]
        else
          @player[name] = val
    for n in ['currentTime', 'volume']
      @[n] = create_prop_func(n)

    @playing = false
    @$player.on 'play', =>
      @playing = true
    @$player.on 'pause', =>
      @playing = false

  load: (url) ->
    @$player.attr('src', url)
    @player.load()

  duration: ->
    return @player.duration

  audio_playable: ->
    return !!@player.canPlayType

  format_playable: (mimetype) ->
    return @player.canPlayType(mimetype)

  play_started: (callback = null) ->
    if callback is null
      return @player.played.length > 0
    else
      @$player.one 'play', callback

  toggle_playback: ->
    if @playing
      @player.pause()
    else
      @player.play()

  seek: (delta) ->
    @player.currentTime += delta

  stop: ->
    @player.pause() if @playing
    @player.currentTime = 0

class gmp.PlayerView extends Backbone.View
  tagName: 'section'
  id: 'player'
  template: _.template($('#player-tpl').html())
  events:
    'click .play-pause': 'play_pause'
    'click .stop': 'stop'
    'click .rewind': 'rewind'
    'click .forward': 'forward'
    'click .volume-control': 'toggle_volume_control_widget'
    'change .volume-control-widget': 'update_volume'
    'click #track-position': 'update_position_from_progress'
  render: ->
    @$el.html(@template())

    @$play_pause = @$('.play-pause > span')
    @$track_position = @$el.children('#track-position')

    @audio = new gmp.HTML5Audio

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

    @$volume_icon = @$('.volume-control > span')
    @$volume_widget = @$('.volume-control-widget')
    @$volume_widget.val(50).change()

    return this

  play: (url) ->
    if @audio.audio_playable()
      if @audio.format_playable('audio/mpeg')
        @audio.load(url)
      else
        window.alert 'You cannot play MP3s natively. Sorry.'
    else
      window.alert 'Cannot play HTML5 audio. Sorry.'

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
    @audio.currentTime((e.offsetX / $(e.target).width()) * @audio.duration())
