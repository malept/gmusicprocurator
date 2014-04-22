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
"""Flask views for the frontend UI."""

from flask import render_template, send_from_directory
import os

from ..app import app

ICO_MIMETYPE = 'image/vnd.microsoft.icon'


@app.route('/')
def main():
    """Main page of the frontend."""
    return render_template('index.html')


@app.route('/favicon.ico')
def favicon():
    """
    favicon.ico route.

    From: http://flask.pocoo.org/docs/patterns/favicon/
    """
    return send_from_directory(os.path.join(app.root_path, 'static'),
                               'favicon.ico', mimetype=ICO_MIMETYPE)
