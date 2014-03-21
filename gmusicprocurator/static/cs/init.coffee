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

# Config for underscore templates:
# * evaluate = [% ... %]
# * interpolate = [[ ... ]]
# * escape: [%- ... %]
_.templateSettings =
  evaluate: /\[%([\s\S]+?)%\]/g
  interpolate: /\[\[([\s\S]+?)\]\]/g
  escape: /\[%-([\s\S]+?)%\]/g

# namespace
gmp = {}

gmp.QUEUE_ID = 'queue'

gmp.song_url = (metadata) ->
  ###
  Generates a song URL based on song metadata.

  :type metadata: Object with ``id`` key
  :rtype: String
  ###
  return "/songs/#{metadata.id}"

class gmp.View extends Backbone.View
  ###
  Abstract base class for common GMP+Backbone views.
  ###
  render: ->
    @$el.html(@template(@model.toJSON()))
    return this

class gmp.SingletonView extends gmp.View
  ###
  Abstract base class for singleton views.
  ###
  renderify: (relative_selector, manip_func) ->
    ###
    Removes the existing view and replaces it with the newly rendered one.

    :param relative_selector: The CSS selector that is used to create a jQuery
                              object that serves as a reference point to attach
                              the view to the document.
    :param manip_func: The jQuery DOM manipulation function that is used to
                       attach the view to the document, relative to the jQuery
                       object created via ``relative_selector``.
    ###
    $("##{@id}").remove()
    $(relative_selector)[manip_func](@render().el)
    @delegateEvents()
