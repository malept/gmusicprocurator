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
human_readable_time = (seconds) ->
  minutes = (seconds / 60).toFixed(0)
  remainder = (seconds % 60).toFixed(0)
  remainder = "0#{remainder}" if remainder < 10
  return "#{minutes}:#{remainder}"

class gmp.PlayerView extends Backbone.View
  tagName: 'section'
  template: _.template($('#player-tpl').html())
  events:
    'click .play-pause': 'play_pause'
    'click .stop': 'stop'
    'click .rewind': 'rewind'
    'click .forward': 'forward'
    'click .volume-control': 'toggle_volume_control_widget'
  render: ->
    @$el.html(@template())
    @$play_pause = @$el.find('.play-pause > span')
    @$track_position = @$el.children('#track-position')

    @$audio = @$el.children('audio')
    @audio = @$audio[0]
    @$audio.on 'pause', =>
      @$play_pause.removeClass('fa-pause').addClass('fa-play')
    @$audio.on 'play', =>
      @$play_pause.removeClass('fa-play').addClass('fa-pause')
    @$audio.on 'durationchange', =>
      @$track_position.attr('max', @audio.duration)
    @$audio.on 'timeupdate', =>
      @$track_position.val(@audio.currentTime)
      cur_pos = human_readable_time(@audio.currentTime)
      total = human_readable_time(@audio.duration)
      @$track_position.attr('title', "#{cur_pos} / #{total}")

    @$volume_icon = @$el.find('.volume-control > span')
    @$volume_widget = @$el.find('.volume-control-widget')
    @$volume_widget.on 'change', (e) =>
      volume = $(e.target).val() / 100
      @audio.volume = volume
      @$volume_icon.removeClass('fa-volume-off fa-volume-down fa-volume-up')
      if volume > 0.5
        volume_cls = 'fa-volume-up'
      else if volume > 0
        volume_cls = 'fa-volume-down'
      else
        volume_cls = 'fa-volume-off'
      @$volume_icon.addClass(volume_cls)
    @$volume_widget.val(50).change()

    @$track_position.on 'click', (e) =>
      return false unless @audio.played.length
      @audio.currentTime = (e.offsetX / $(e.target).width()) * @audio.duration
    return this

  play: (url) ->
    if !!@audio.canPlayType
      if @audio.canPlayType('audio/mpeg')
        @audio.setAttribute('src', url)
        @audio.load()
      else
        window.alert 'You cannot play MP3s natively. Sorry.'
    else
      window.alert 'Cannot play HTML5 audio. Sorry.'

  play_pause: ->
    return false unless @audio.played.length
    if @$play_pause.hasClass('fa-play')
      @audio.play()
    else
      @audio.pause()
    return true

  stop: ->
    return false unless @audio.played.length
    @audio.pause() if @$play_pause.hasClass('fa-pause')
    @audio.currentTime = 0

  rewind: ->
    return false unless @audio.played.length
    return false if @$play_pause.hasClass('fa-play')
    @audio.currentTime -= 5

  forward: ->
    return false unless @audio.played.length
    return false if @$play_pause.hasClass('fa-play')
    @audio.currentTime += 5

  toggle_volume_control_widget: ->
    @$volume_widget.toggleClass('invisible')
