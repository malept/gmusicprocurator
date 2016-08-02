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
"""GMusicProcurator Flask app module."""

try:
    from appdirs import user_config_dir  # appdirs >= 1.3.0
except ImportError:
    from appdirs import user_data_dir as user_config_dir
from flask import Flask
import os

SETTINGS_VAR = 'GMUSICPROCURATOR_SETTINGS'
CFG_FILENAME = 'gmusicprocurator.cfg'
os.environ.setdefault(SETTINGS_VAR,
                      os.path.join(user_config_dir('gmusicapi'), CFG_FILENAME))

app = Flask(__name__)
app.config.from_object('gmusicprocurator.default_settings')
app.config.from_envvar(SETTINGS_VAR)

if app.config['GMP_FRONTEND_ENABLED']:
    from flask_assets import Environment
    assets = Environment(app)
    os.environ['PATH'] = \
        '{}/.bin:{}'.format(app.config['GMP_NODE_MODULES_DIR'],
                            os.environ['PATH'])
else:
    assets = None

if app.config['GMP_OFFLINE_MODE']:
    music = None
else:
    from gmusicapi import Mobileclient
    from keyring.core import get_password, load_keyring, set_keyring
    keyring_backend = app.config.get('KEYRING_BACKEND')
    if keyring_backend:
        set_keyring(load_keyring(keyring_backend))
    music = Mobileclient()
    email = app.config['GACCOUNT_EMAIL']
    password = get_password('gmusicprocurator', email)
    if password is None:
        music = None
    else:
        music.login(email, password, app.config.get('GACCOUNT_DEVICE_ID'))

if app.debug and app.config['GMP_MEMORY_PROFILER']:
    from guppy import hpy
    heapy = hpy()
else:
    heapy = None

__all__ = ('app', 'assets', 'heapy', 'music')
