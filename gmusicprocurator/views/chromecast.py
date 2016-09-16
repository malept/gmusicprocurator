# -*- coding: utf-8 -*-
#
# Copyright (C) 2016  Mark Lee
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
"""Flask views for the Chromecast proxy."""

from functools import wraps
import pychromecast
from flask import g, url_for
from werkzeug.exceptions import ServiceUnavailable

from ..app import app


def connect_to_chromecast():
    """Create a new Chromecast object given the configured friendly name."""
    cc_name = app.config['GMP_CHROMECAST_NAME']
    return pychromecast.get_chromecast(friendly_name=cc_name)


def get_media_controller():
    """
    Retrieve the media controller from the possibly cached Chromecast object.

    :return: MediaController from pychromecast
    """
    cc = getattr(g, '_cc', None)
    if cc is None:
        cc = g._cc = connect_to_chromecast()
        print cc
        if cc is None:
            raise ServiceUnavailable()
    return cc.media_controller


def queued():
    """Basic HTTP 202 (Accepted) response."""
    return ('', 202, [])


def cc_controller(f):
    """View controller for controlling a Chromecast."""
    @wraps(f)
    def control_chromecast(*args, **kwargs):
        mc = get_media_controller()
        result = f(mc, *args, **kwargs)
        if result is None:
            result = queued()
        return result

    return control_chromecast


@app.route('/chromecast/play/<song_id>')
@cc_controller
def play(mc, song_id):
    """Play a given Google Music track via the Chromecast."""
    url = url_for('get_song', _external=True, song_id=song_id)
    mc.play_media(url, 'audio/mp3')
