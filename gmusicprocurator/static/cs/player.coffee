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

gmp.MAX_FAILED_TRACKS = 4

####
# Functions
####

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

####
# Models
####

class gmp.PlayerSettings extends Backbone.Model
  localStorage: new Backbone.LocalStorage('GMusicProcurator.Settings')
  defaults:
    volume: 50
    play_mode: 0

  play_modes: [
    'one',
    'play to end',
    'continuous',
    'shuffle',
  ]
  play_mode_icons:
    'continuous': 'fa-retweet'
    'play to end': 'fa-retweet play-to-end'
    'shuffle': 'fa-random'

  constructor: (data, options) ->
    data ||= {}
    data.id = 'singleton'
    super(data, options)
    @play_mode_icons.one = (icon) ->
      icon.addClass('fa fa-retweet fa-stack-1x repeat-one')
      icon.append($('<span class="fa-stack-1x">1</span>'))
    @fetch()
    @on 'change', => @save()

  play_mode_text: -> return @play_modes[@get('play_mode')]

  play_mode_icon: -> return @play_mode_icons[@play_mode_text()]

  next_play_mode: ->
    play_mode = @get('play_mode')
    @set('play_mode', (play_mode + 1) % @play_modes.length)

####
# Views
####

class gmp.NowPlayingView extends gmp.SingletonView
  tagName: 'span'
  id: 'now-playing'
  template: gmp.get_template('now-playing', 'track')


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
    'click .play-mode': 'select_play_mode'
    'click .volume-control': 'toggle_volume_control_widget'
    'change .volume-control-widget': 'update_volume'
    'click #track-position': 'update_position_from_progress'

  constructor: (options) ->
    super(options)
    @settings = options.settings

  render: ->
    @$el.html(@template())

    @$play_pause = @$el.find('.play-pause').children('span')
    @$track_position = @$el.children('#track-position')

    @audio = gmp.load_audio_backend()
    return this unless @audio?

    do_next_track = =>
      @next_track() if @settings.play_mode_text() != 'one'

    # For some reason, can't transform these into view-based events
    @audio.pause =>
      @$play_pause.replaceClass('fa-pause', 'fa-play')
    @audio.play =>
      @$play_pause.replaceClass('fa-play', 'fa-pause')
    @audio.timeupdate =>
      @$track_position.val(@audio.currentTime())
      cur_pos = gmp.human_readable_time(@audio.currentTime())
      total = gmp.human_readable_time(@current_duration)
      @$track_position.attr('title', "#{cur_pos} / #{total}")
    @audio.play_started =>
      @failed_tracks = 0
      @$play_pause.replaceClass('fa-spinner fa-spin', 'fa-pause')
      tview = new gmp.NowPlayingView({model: @current_track_metadata})
      tview.renderify('#player > nav', 'prepend')
      icon = '/favicon.ico'
      track = @current_track_metadata.attributes
      @current_duration = track.durationMillis / 1000
      @$track_position.attr('max', @current_duration)
      icon = track.albumArtRef[0].url if track.albumArtRef?.length > 0
      gmp.notify "Now Playing",
        icon: icon
        body: "#{track.title} - #{track.artist}: #{track.album}"
        tag: track.id
    @audio.error =>
      @failed_tracks++
      if @failed_tracks < gmp.MAX_FAILED_TRACKS
        msg = 'Could not load track, skipping.'
        do_next_track()
      else
        msg = 'Could not load track. Please check your connection.'
        @$play_pause.replaceClass('fa-spinner fa-spin', 'fa-play')
      gmp.notify 'Error loading track',
        body: msg
        tag: 'track-load-error'
    @audio.ended -> do_next_track()

    @$volume_icon = @$el.find('.volume-control').children('span')
    @$volume_widget = @$el.find('.volume-control-widget')
    @$volume_widget.val(@settings.get('volume')).change()

    @play_mode_btn = @$el.find('.play-mode')
    @set_play_mode_button(@play_mode_btn)

    @failed_tracks = 0

    return this

  play: (metadata, url) ->
    url = gmp.song_url(metadata) unless url?
    if @audio?.audio_playable()
      if @audio.mp3_playable()
        @current_track_metadata = metadata
        @audio.load(url)
        @$play_pause.replaceClass('fa-play fa-pause', 'fa-spinner fa-spin')
      else
        window.alert 'You cannot play MP3s natively. Sorry.'
    else
      window.alert 'Cannot play HTML5 audio. Sorry.'

  _select_track: (func_name) ->
    entry = @model[func_name](@settings.play_mode_text())
    return unless entry?
    track = entry.get('track')
    @stop()
    @play(track)

  previous_track: ->
    @_select_track('previous')

  next_track: ->
    @_select_track('next')

  ####
  # Event Handlers
  ####

  play_pause: ->
    if !@audio.play_started() && 0 == @model.get('current_track')
      @model.seek(0, true)
    else
      @audio.toggle_playback()

  stop: ->
    return false unless @audio.play_started()
    @audio.stop()
    @$track_position.val(0)
    return true

  rewind: ->
    return false unless @audio.play_started()
    @audio.seek(-5)

  forward: ->
    return false unless @audio.play_started()
    @audio.seek(5)

  set_play_mode_button: (button) ->
    icon = button.children()
    mode = @settings.play_mode_text()
    button.attr('title', "Play mode: #{mode}")
    key = @settings.play_mode_icon()
    icon.removeClass().text('').children().remove()
    if typeof key is 'string'
      icon.addClass("fa #{key}")
    else
      key(icon)

  select_play_mode: (e) ->
    e.stopImmediatePropagation()
    @settings.next_play_mode()
    @set_play_mode_button(@play_mode_btn)
    return false

  toggle_volume_control_widget: ->
    @$volume_widget.toggleClass('invisible')

  update_volume: (e) =>
    value = $(e.target).val()
    @settings.set('volume', value)
    volume = value / 100
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
    @audio.currentTime((offset / $tgt.width()) * @current_duration)

  is_playing: ->
    return @audio.is_playing()
