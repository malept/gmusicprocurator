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

gmp.get_template = (id) ->
  ###
  Shortcut for retrieving a template by ID.
  ###
  return _.template($("##{id}-tpl").html())

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
    ###
    Renders a template using the data from :meth:`render_data`, and puts it in
    the view's element.

    :return: The view being operated on
    :rtype: :class:`gmp.View`
    ###
    @$el.html(@template(@render_data()))
    return this

  render_data: ->
    ###
    The data used by the view to render the template.

    :rtype: :class:`Object`
    ###
    return @model.toJSON()

class gmp.SingletonView extends gmp.View
  ###
  Abstract base class for singleton views.
  ###
  replace: (relative_selector, manip_func) ->
    ###
    Removes the existing view and replaces it with the currently rendered one.

    :param relative_selector: The CSS selector that is used to create a jQuery
                              object that serves as a reference point to attach
                              the view to the document.
    :param manip_func: The jQuery DOM manipulation function that is used to
                       attach the view to the document, relative to the jQuery
                       object created via ``relative_selector``.
    ###
    $("##{@id}").remove()
    $(relative_selector)[manip_func](@el)
    @delegateEvents()
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
    @render()
    @replace(relative_selector, manip_func)
