====================
``gmusicprocurator``
====================

A proxy for Google Music streaming. This mini webapp is inspired by/based
on GMusicProxy_.

.. _GMusicProxy: http://gmusicproxy.net

Quick Install
-------------

.. note::

   This has only been tested on Python 2.7.

Create a config file in ``~/.config/gmusicapi/gmusicprocurator.cfg`` that looks like
this:

.. code-block:: python

   GACCOUNT_EMAIL = 'my-google-account@gmail.com'
   GACCOUNT_PASSWORD = 'my-password'
   GACCOUNT_DEVICE_ID = 'my-device-id'

where ``GACCOUNT_DEVICE_ID`` is the ID of one of your mobile devices that is
associated with your Google account.

Then run the following:

.. code-block:: console

   $ git clone git://github.com/malept/gmusicprocurator.git
   $ cd gmusicprocurator
   $ pip install -r requirements.txt
   $ python -m gmusicprocurator runserver

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
