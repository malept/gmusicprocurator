# -*- coding: utf-8 -*-
# vim: set ts=2 sts=2 sw=2 :
#
###! Copyright (C) 2015 Mark Lee, under the GPL (version 3+) ###
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

class gmp.SearchResults extends Backbone.Model
  url: '/search'

  parse: (response) ->
    response.song_hits = new AlpacAudio.TrackList(tracks: response.song_hits)
    response.song_hits.dont_scroll = true
    if gmp.song_search_results?
      gmp.song_search_results.model = response.song_hits
    else
      gmp.song_search_results =
        new AlpacAudio.TrackListView(model: response.song_hits)
    return response


class gmp.SearchResultsView extends AlpacAudio.SingletonView
  className: 'scrollable-container'
  id: 'search-results'
  tagName: 'section'
  template: AlpacAudio.get_template('search-results')

  constructor: (options = {}) ->
    options.model ?= new gmp.SearchResults
    super(options)


class gmp.SearchBox extends AlpacAudio.SingletonView
  className: 'pure-form'
  id: 'search'
  tagName: 'form'
  template: AlpacAudio.get_template('search-form')

  events:
    'submit': 'send_query'

  render_data: ->
    return query: @query

  search: (query, on_success) ->
    return false if query.replace(/\s+/g, '').length is 0
    gmp.search_results ?= new gmp.SearchResultsView
    gmp.search_results.model.fetch
      contentType: 'application/json'
      dataType: 'json'
      data: JSON.stringify(query: query)
      method: 'post'
      success: on_success

  send_query: (e) ->
    e.preventDefault()
    query = @$el.find('[name=query]').val()
    window.location.hash = "#/search/#{query}"
    return false


class gmp.SearchRouter extends Backbone.Router
  routes:
    'search/:query': 'search'

  search: (query) ->
    $('#search [name=query]').val(query)
    gmp.search_box.search query, ->
      gmp.search_results.renderify('main nav:first', 'after')
      gmp.song_search_results.renderify('#search-results section + h4', 'after')
