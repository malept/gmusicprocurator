# -*- coding: utf-8 -*-
#
# Copyright (C) 2014  Mark Lee
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

from flask import render_template
from flask.ext.assets import Bundle

from ..app import app, assets

normalize = 'vendor/pure/base.css'

typography = Bundle('scss/typography.scss', filters='scss',
                    output='scss/typography.out.css')

pure_modules = [
    'buttons',
    'grids',
    'tables',
]

pure = Bundle(*['vendor/pure/{0}.css'.format(f) for f in pure_modules])

main_css = Bundle('scss/main.scss', filters='scss',
                  output='scss/main.out.css')

css = Bundle(normalize, typography, pure, main_css, filters='cssmin',
             output='all.min.css')
assets.register('css', css)

vendor = Bundle('vendor/jquery/dist/jquery.js',
                'vendor/underscore/underscore.js',
                'vendor/backbone/backbone.js')

cs_modules = [
    'playlist',
    'app',
]

cs = Bundle(*['cs/{0}.coffee'.format(f) for f in cs_modules],
            filters='coffeescript', output='cs/out.js')
js = Bundle(vendor, cs, filters='closure_js', output='all.min.js')
assets.register('js', js)


@app.route('/')
def main():
    return render_template('index.html')
