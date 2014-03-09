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

from flask.ext.assets import Bundle
from webassets.filter import ExternalTool, register_filter

from .app import assets


class ImporterFilter(ExternalTool):
    name = 'importer_js'
    method = 'open'
    options = {
        'binary': 'IMPORTERJS_BIN',
        'extra_args': 'IMPORTERJS_EXTRA_ARGS',
    }

    def setup(self):
        self.argv = [
            self.binary or 'importer',
            '{1}',  # source_path
            '{{output}}',
        ]
        if self.extra_args:
            self.argv.extend(self.extra_args)

register_filter(ImporterFilter)


def bundlify(fmt, modules, **kwargs):
    '''Creates a Bundle based on a path format and a list of modules.'''
    return Bundle(*[fmt.format(f) for f in modules], **kwargs)

normalize = 'vendor/pure/base.css'

# typography is in a separate bundle so it can be placed before pure
typography = Bundle('scss/typography.scss', filters='scss',
                    output='scss/typography.out.css')

pure_modules = [
    'buttons',
    'grids',
    'tables',
]

pure = bundlify('vendor/pure/{0}.css', pure_modules)

main_css = Bundle('scss/main.scss', filters='scss',
                  output='scss/main.out.css')

css = Bundle(normalize, typography, pure, main_css, filters='cssmin',
             output='all.min.css')
assets.register('css', css)

aurora = Bundle('vendor/aurora.js/browser.coffee', filters='importer_js',
                output='vendor/aurora.built.js')
mp3 = Bundle('vendor/mp3.js/mp3.js', filters='importer_js',
             output='vendor/mp3.built.js')
aurora_mp3 = Bundle(aurora, mp3, filters='uglifyjs', output='auroramp3.min.js')
assets.register('aurora_mp3', aurora_mp3)

vendor = Bundle('vendor/jquery/dist/jquery.js',
                'vendor/underscore/underscore.js',
                'vendor/backbone/backbone.js')

cs_modules = [
    'init',
    'backends/webaudio',
    'backends/aurora',
    'player',
    'playlist',
    'app',
]

cs = bundlify('cs/{0}.coffee', cs_modules, filters='coffeescript',
              output='cs/out.js')
js = Bundle(vendor, cs, filters='uglifyjs', output='all.min.js')
assets.register('js', js)
