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
"""
App-specific Flask settings.

Standard
--------

.. attribute:: GMP_SONG_FILTERS

    A tuple of callable filters used on streaming MP3 data. By default, it
    looks like:

    .. code-block:: python

        GMP_SONG_FILTERS = (
            'add_id3_tags_to_mp3',
        )

    Tuple items can be either strings (built-in to the app) or callables.
    Callables have the following signature::

        def (str song_id, io.BytesIO data) -> io.BytesIO

.. attribute:: GMP_EMBED_ALBUM_ART

    Embed album art in the songs' ID3 tags (assuming that ID3 tags are being
    embedded in the MP3s). Defaults to :data:`False`.

Development
-----------

Settings that should only be configured if you are developing GMusicProcurator
and/or you know what you're doing.

.. attribute:: GMP_OFFLINE_MODE

    If set to :data:`True`, the proxy views will only return the HTTP status
    code ``503`` (Service Unavailable). It is on by default only when Read the
    Docs is building the documentation.

.. attribute:: GMP_MEMORY_PROFILER

    Uses ``heapy`` to examine what objects are using the most memory in the
    app. Requires installing guppy_ (via ``pip install guppy``). When the
    server is running, send the ``SIGUSR1`` signal to the main process, and it
    will print out a frequency table of allocated objects, and shut down
    the server.

    .. _guppy: http://guppy-pe.sourceforge.net/#Heapy
"""

import os

GMP_SONG_FILTERS = (
    'add_id3_tags_to_mp3',
)

GMP_EMBED_ALBUM_ART = False

GMP_OFFLINE_MODE = os.environ.get('READTHEDOCS') == 'True'

GMP_MEMORY_PROFILER = False
