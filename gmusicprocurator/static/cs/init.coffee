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

#
# Generates a song URL based on song metadata.
#
gmp.song_url = (metadata) ->
  return "/songs/#{metadata.id}"

#
# Abstract base class for common GMP+Backbone views.
#
class gmp.View extends Backbone.View
  render: ->
    @$el.html(@template(@model.toJSON()))
    return this

#
# Abstract base class for singleton views.
#
class gmp.SingletonView extends gmp.View
  #
  # Removes the existing view and replaces it with the newly rendered one.
  #
  renderify: (relative_selector, manip_func) ->
    $("##{@id}").remove()
    $(relative_selector)[manip_func](@render().el)
    @delegateEvents()
