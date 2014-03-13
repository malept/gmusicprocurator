====================
``gmusicprocurator``
====================

A proxy/HTML5 frontend for Google Music streaming. This mini webapp is
inspired by GMusicProxy_.

.. _GMusicProxy: http://gmusicproxy.net

Features
--------

* XSPF playlists
* Option to ID3v2-tag MP3 streams

  * Option to embed album art in MP3 streams
* Browse playlists via an HTML5 frontend
* Stream playlists in the browser without using Flash or other browser plugins,
  in browsers that support HTML5 Audio

Quick Install
-------------

.. note::

   This has only been tested on Python 2.7.

   These abbreviated instructions are for running the proxy only. For proxy +
   frontend instructions, plus detailed requirements, consult ``INSTALL.rst``.

Create a config file in ``~/.config/gmusicapi/gmusicprocurator.cfg`` that looks like
this:

.. code-block:: python

   GACCOUNT_EMAIL = 'my-google-account@gmail.com'
   GACCOUNT_PASSWORD = 'my-password'

Then run the following:

.. code-block:: console

   $ git clone https://github.com/malept/gmusicprocurator.git
   $ cd gmusicprocurator
   $ pip install -r requirements.txt
   $ python -m gmusicprocurator list_devices --no-desktop

The last command will print out a list of mobile devices that are registered
with Google Music. Select one of them and add the following to the config file
from above (substituting ``REPLACE_ME`` with the ID, which is after the colon
in the device ID printout):

.. code-block:: python

   GACCOUNT_DEVICE_ID = 'REPLACE_ME'

Once the config file is saved, the server can be started.

.. code-block:: console

   $ python -m gmusicprocurator runserver

Currently, the proxy assumes that you know the playlist ID. You can access the
(XSPF) playlist in the media player of your choice via the URL
``http://localhost:5000/playlists/$PLAYLIST_ID``, replacing ``$PLAYLIST_ID``
with the proper playlist ID.

Configuration
-------------

In addition to the Google Account settings mentioned above, you can set the
following:

``GMP_SONG_FILTERS``
    A tuple of callable filters used on streaming MP3 data. By default, it
    looks like:

    .. code-block:: python

        GMP_SONG_FILTERS = (
            'add_id3_tags_to_mp3',
        )

    Tuple items can be either strings (built-in to the app) or callables.
    Callables have the following signature::

        func(str song_id, io.BytesIO data) -> io.BytesIO

``GMP_EMBED_ALBUM_ART``
    Embed album art in the songs' ID3 tags. Defaults to ``False``.

Legal
-----

This web application is licensed under the terms of the GNU General Public
License (GNU GPL), version 3 or later, unless otherwise noted in the source
files. See ``LICENSE`` for the full license text.

This project is not affiliated in any way to Google or any of Google's
music apps.
