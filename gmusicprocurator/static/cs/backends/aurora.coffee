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

class gmp.AuroraAudio
  ###
  Uses Aurora.js + MP3.js to play MP3s.
  ###
  constructor: ->
    unless AV?
      # load Aurora.js + MP3.js if they aren't loaded
      $('head').append($('<script src="/static/auroramp3.min.js"/>'))

    @dispatcher = _.clone(Backbone.Events)

    create_proxy_evt_func = (name) =>
      return (handler) =>
        if handler?
          @dispatcher.on(name, handler)
        else
          @player[name]()
          @dispatcher.trigger(name)
    for n in ['play', 'pause']
      @[n] = create_proxy_evt_func(n)

    create_evt_func = (name) =>
      @dispatcher.on 'create_player', =>
        @player.on name, => @dispatcher.trigger(name)
      return (handler) =>
        if handler?
          @dispatcher.on(name, handler)
        else
          @dispatcher.trigger(name)
    @timeupdate = create_evt_func('progress')
    @ended = create_evt_func('end')
    @error = create_evt_func('error')

  _handle_player: (handler) ->
    if @player?
      handler()
    else
      @dispatcher.once 'create_player', ->
        handler()

  volume: (val = null) ->
    if val is null
      return @player.volume / 100
    else
      @_handle_player => @player.volume = val * 100

  load: (url) ->
    prev_player = false
    if @player?
      prev_player = true
      vol = @volume()
      @player.stop()
    @player = AV.Player.fromURL(url)
    @dispatcher.trigger 'create_player'
    @started_play = false
    @player.once 'ready', =>
      @started_play = true
      @dispatcher.trigger('ready')
    @player.once 'end', =>
      @started_play = false
      @dispatcher.trigger('pause')
    @volume(vol) if prev_player
    @play()

  currentTime: (val = null) ->
    if val is null
      return @player.currentTime / 1000
    else
      setter = =>
        @player.seek(val * 1000)
        @player.play()
      @_handle_player -> setter()

  audio_playable: ->
    true

  mp3_playable: ->
    return AV.Decoder.find('mp3')?

  play_started: (handler) ->
    if handler?
      @dispatcher.on('ready', handler)
    else
      return @started_play

  toggle_playback: ->
    @player.togglePlayback()
    @dispatcher.trigger(if @player.playing then 'play' else 'pause')

  seek: (delta) ->
    @player.seek((@currentTime() + delta) * 1000)

  stop: ->
    @player.pause()
    @player.seek(0)
    @dispatcher.trigger('pause')

  is_playing: ->
    return @player?.playing
