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

from ConfigParser import SafeConfigParser
from flask import Flask
from gmusicapi import Mobileclient
from xdg import BaseDirectory

CFG_FILENAME = 'gmusicprocurator.ini'

app = Flask(__name__)

cfg = SafeConfigParser()
read_files = cfg.read(BaseDirectory.load_config_paths(CFG_FILENAME))
if len(read_files) == 0:
    raise RuntimeError('No config file found.')

music = Mobileclient()
music.login(cfg.get('credentials', 'email'),
            cfg.get('credentials', 'password'))
device_id = cfg.get('credentials', 'device-id')

__all__ = ['app', 'music', 'device_id']
