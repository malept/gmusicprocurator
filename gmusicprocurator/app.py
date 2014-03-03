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

from flask import Flask
from flask.ext.assets import Environment
from gmusicapi import Mobileclient
import os
from xdg import BaseDirectory

SETTINGS_VAR = 'GMUSICPROCURATOR_SETTINGS'
CFG_FILENAME = 'gmusicprocurator.cfg'
os.environ.setdefault(SETTINGS_VAR,
                      BaseDirectory.load_first_config(CFG_FILENAME))

app = Flask(__name__)
app.config.from_object('gmusicprocurator.default_settings')
app.config.from_envvar(SETTINGS_VAR)

assets = Environment(app)

music = Mobileclient()
music.login(app.config['GACCOUNT_EMAIL'],
            app.config['GACCOUNT_PASSWORD'])

if app.config['GMP_CACHE_SONGS'] and \
   not os.path.isdir(app.config['GMP_CACHE_DIR']):
    os.makedirs(app.config['GMP_CACHE_DIR'])

__all__ = ['app', 'assets', 'music']
