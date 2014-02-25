# -*- coding: utf-8 -*-
#
# I have no idea what the license of the original code is.
# Maybe the 3-clause BSD license?
# Original Copyright 2012, Mark Watkinson
#
# Original URL:
#http://blog.asgaard.co.uk/2012/08/03/http-206-partial-content-for-flask-python
#
# Modifications Copyright (C) 2014  Mark Lee
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

from flask import g, request, send_file, Response
import mimetypes
import os
import re

from . import app


@app.after_request
def after_request(response):
    response.headers.add('Accept-Ranges', 'bytes')
    return response


def send_file_partial(path):
    '''
    Simple wrapper around send_file which handles HTTP 206 Partial Content
    (byte ranges)
    TODO: handle all send_file args, mirror send_file's error handling
    (if it has any)
    '''
    range_header = request.headers.get('Range', None)
    if not range_header:
        return send_file(path)

    size = os.path.getsize(path)
    byte1, byte2 = 0, None

    m = re.search('(\d+)-(\d*)', range_header)
    groups = m.groups()

    if groups[0]:
        byte1 = int(groups[0])
    if groups[1]:
        byte2 = int(groups[1])

    length = size - byte1
    if byte2 is not None:
        length = byte2 - byte1 + 1

    data = None

    if not os.path.isabs(path):
        path = os.path.join(g.current_app.root_path, path)
    with open(path, 'rb') as f:
        f.seek(byte1)
        data = f.read(length)

    rv = Response(data, 206, mimetype=mimetypes.guess_type(path)[0],
                  direct_passthrough=True)
    cr = 'bytes {0}-{1}/{2}'.format(byte1, byte1 + length - 1, size)
    rv.headers.add('Content-Range', cr)

    return rv
