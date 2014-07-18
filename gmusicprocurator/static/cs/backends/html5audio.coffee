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

gmp.MP3_FMT = 'audio/mpeg'

class gmp.HTML5Audio
  ###
  Uses HTMLAudioElement to play MP3s.
  ###
  constructor: ->
    @player = new Audio()
    @$player = $(@player)
    @$player.attr('autoplay', 'autoplay')

    create_evt_func = (name, args...) ->
      return (handler) ->
        if handler?
          @$player.on name, handler
        else if !!@player[name]
          @player[name](args...)
        else
          @$player.trigger(name, args)
    for n in ['play', 'pause', 'timeupdate', 'ended', 'error']
      @[n] = create_evt_func(n)

    create_prop_func = (name) ->
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

  audio_playable: ->
    return !!@player.canPlayType

  mp3_playable: ->
    return @player.canPlayType(gmp.MP3_FMT)

  play_started: (handler) ->
    if handler?
      @$player.on 'play', handler
    else
      return @player.played.length > 0

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

  is_playing: ->
    return @playing
