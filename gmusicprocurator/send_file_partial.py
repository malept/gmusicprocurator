# -*- coding: utf-8 -*-
#
# I have no idea what the license of the original code is.
# Maybe the 3-clause BSD license?
# Original Copyright 2012, Mark Watkinson
#
# Original URL:
#http://blog.asgaard.co.uk/2012/08/03/http-206-partial-content-for-flask-python

from flask import request, send_file, Response
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
    g = m.groups()

    if g[0]:
        byte1 = int(g[0])
    if g[1]:
        byte2 = int(g[1])

    length = size - byte1
    if byte2 is not None:
        length = byte2 - byte1

    data = None
    with open(path, 'rb') as f:
        f.seek(byte1)
        data = f.read(length)

    rv = Response(data, 206, mimetype=mimetypes.guess_type(path)[0],
                  direct_passthrough=True)
    cr = 'bytes {0}-{1}/{2}'.format(byte1, byte1 + length - 1, size)
    rv.headers.add('Content-Range', cr)

    return rv
