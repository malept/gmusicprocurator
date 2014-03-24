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
# Uses Aurora.js + MP3.js to play MP3s.
#
class gmp.AuroraAudio
  constructor: ->
    unless AV?
      # load Aurora.js + MP3.js if they aren't loaded
      head = $('head')
      # TODO figure out if there's a better way to do this
      # without adding a performance hit for browsers which
      # don't use this backend
      head.append($('<script src="/static/auroramp3.min.js"/>'))

    @dispatcher = _.clone(Backbone.Events)

    create_proxy_evt_func = (name) ->
      return (callback = null) ->
        if !!callback
          @dispatcher.on name, callback
        else
          @player[name]()
          @dispatcher.trigger(name)
    for n in ['play', 'pause']
      @[n] = create_proxy_evt_func(n)

    create_evt_func = (name) ->
      return (callback = null) ->
        if !!callback
          if @player?
            @player.on name, callback
          else
            @dispatcher.on 'create_player', =>
              @player.on name, callback
        else
          @dispatcher.trigger(name)
    @durationchange = create_evt_func('duration')
    @timeupdate = create_evt_func('progress')

    create_prop_func = (name) ->
      return (val = null) ->
        if val is null
          result = @player[name]
          return result
        else
          if @player?
            @player[name] = val
          else
            @dispatcher.once 'create_player', =>
              @player[name] = val
    @volume = create_prop_func('volume')

  load: (url) ->
    @player = AV.Player.fromURL(url)
    @dispatcher.trigger 'create_player'
    @started_play = false
    @player.once 'ready', =>
      @started_play = true
    @player.once 'end', =>
      @started_play = false
      @dispatcher.trigger('pause')
    @play()

  currentTime: (val = null) ->
    if val is null
      return @player.currentTime / 1000
    else
      setter = =>
        @player.seek(val * 1000)
        @player.play()
      if @player?
        setter()
      else
        @dispatcher.once 'create_player', ->
          setter()

  duration: ->
    return @player.duration / 1000

  audio_playable: ->
    true

  mp3_playable: ->
    return AV.Decoder.find('mp3')?

  play_started: (callback = null) ->
    if callback is null
      return @started_play
    else
      @player.once 'ready', callback

  toggle_playback: ->
    @player.togglePlayback()
    @dispatcher.trigger(if @player.playing then 'play' else 'pause')

  seek: (delta) ->
    @player.seek((@currentTime() + delta) * 1000)

  stop: ->
    @player.stop()

  is_playing: ->
    return @player?.playing
