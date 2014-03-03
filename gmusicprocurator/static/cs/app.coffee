# -*- coding: utf-8 -*-
# vim: set ts=2 sts=2 sw=2 :

class gmp.AppView extends Backbone.View
  el: 'main'

  initialize: ->
    @listenTo gmp.playlists, 'add', (playlist) ->
      view = new gmp.PlaylistEntryView({model: playlist})
      $('#playlists').append(view.render().el)
    $('#get-playlists').on 'click', ->
      btn = this
      $.getJSON '/playlists', (data) ->
        gmp.playlists.add(data.playlists)
        $('#playlists-header').show()
        $(btn).hide()

####
# Initializer
####

$ ->
  new gmp.AppView
