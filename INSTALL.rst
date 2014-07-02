============
Installation
============

Requirements
------------

Backend
~~~~~~~

* Python 2.7 (only tested with CPython)
* virtualenv (optional, but recommended)
* git (some packages are only installable via version control)

Frontend
~~~~~~~~

* Either libsass-python_ or the reference implementation of Sass_ (which
  requires Ruby)
* Node.js + NPM
* Bower (``npm install -g bower``)
* CoffeeScript (``npm install -g coffee-script``)
* UglifyJS2 (``npm install -g uglify-js``)
* Browserify and related dependencies (``npm install -g browserify coffeeify browserify-shim``)

.. _libsass-python: http://dahlia.kr/libsass-python/
.. _Sass: http://sass-lang.com/

Browser
~~~~~~~

Any web browser which `supports the HTML5 audio element`_ is supported, except
IE9, due to the layout CSS.

.. _supports the HTML5 audio element: http://caniuse.com/audio

Instructions
------------

Create a config file. The location depends on the OS where you're installing
this app:

OS X:
    ``~/Library/Application Support/gmusicapi/gmusicprocurator.cfg``
Linux:
    ``~/.config/gmusicapi/gmusicprocurator.cfg``
Windows:
    *If you want to use this on Windows, let me know. I have no idea whether it
    will work correctly.*

The contents of the file will look like this:

.. code-block:: python

   GACCOUNT_EMAIL = 'my-google-account@gmail.com'

Then run the following (lines that start with ``#`` are comments, not commands):

.. code-block:: shell-session

   # Get the code
   user@host:Code$ git clone https://github.com/malept/gmusicprocurator.git
   user@host:Code$ cd gmusicprocurator
   # Create a new virtual environment
   user@host:gmusicprocurator$ virtualenv venv
   user@host:gmusicprocurator$ source venv/bin/activate
   (venv)user@host:gmusicprocurator$ pip install -r requirements.txt
   # Only run the next line if you wish to use libsass-python instead of the
   # Ruby version of Sass:
   (venv)user@host:gmusicprocurator$ pip install libsass
   (venv)user@host:gmusicprocurator$ python -m gmusicprocurator set_password

The last command will activate an interactive prompt that will store your
Google account password (or, if your account has two-factor authentication
enabled, your application-specific password) into the operating system's
password storage service.

Once your password is set, you will need to associate GMusicProcurator with one
of your mobile devices. Run the following command to list the devices:

.. code-block:: shell-session

   (venv)user@host:gmusicprocurator$ python -m gmusicprocurator list_devices --no-desktop

Select one of them and add the following to the config file from above
(substituting ``REPLACE_ME`` with the ID, which is after the colon in the
device ID printout):

.. code-block:: python

   GACCOUNT_DEVICE_ID = 'REPLACE_ME'

If you do not want to run the frontend, add the following to the config file:

.. code-block:: python

   GMP_FRONTEND_ENABLED = False

Once the config file is saved, the server can be started.

.. code-block:: shell-session

   (venv)user@host:gmusicprocurator$ python -m gmusicprocurator runserver

By default, it runs at ``localhost:5000``. For assistance on how to change
these settings, run ``python -m gmusicprocurator runserver --help``.

Currently, the proxy assumes that you know the playlist ID. You can access the
(XSPF) playlist in the media player of your choice via the URL
``http://localhost:5000/playlists/$PLAYLIST_ID``, replacing ``$PLAYLIST_ID``
with the proper playlist ID.

Frontend-specific
~~~~~~~~~~~~~~~~~

If you want to run the frontend as well, run the following before you start the
server:

.. code-block:: shell-session

   (venv)user@host:gmusicprocurator$ bower install -p
