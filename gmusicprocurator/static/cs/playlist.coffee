# -*- coding: utf-8 -*-
# vim: set ts=2 sts=2 sw=2 :

# Config for mustache-style templates
# Unfortunately, since we're using Jinja, this can't be used.
###
_.templateSettings =
  evaluate: /\{%([\s\S]+?)%\}/g
  interpolate: /\{\{([\s\S]+?)\}\}/g
  escape: /\{%-([\s\S]+?)%\}/g
###
_.templateSettings =
  evaluate: /\[%([\s\S]+?)%\]/g
  interpolate: /\[\[([\s\S]+?)\]\]/g
  escape: /\[%-([\s\S]+?)%\]/g

# namespace
gmp = {}

####
# Models / Collections
####

class gmp.Playlist extends Backbone.Model
  active: false

  constructor: (data, options) ->
    tracks = data.tracks
    data.tracks = new gmp.PlaylistEntries(tracks)
    super(data, options)

class gmp.PlaylistCollection extends Backbone.Collection
  model: gmp.Playlist

gmp.playlists = new gmp.PlaylistCollection

class gmp.PlaylistEntry extends Backbone.Model

class gmp.PlaylistEntries extends Backbone.Collection
  model: gmp.PlaylistEntry

####
# Views
####

class gmp.PlaylistView extends Backbone.View
  tagName: 'table'

class gmp.PlaylistEntryView extends Backbone.View
  tagName: 'li'
  template: _.template($('#playlists-tpl').html())
  render: ->
    @$el.html(@template(@model.toJSON()))
    return this
