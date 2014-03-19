===============================
Installing ``gmusicprocurator``
===============================

Requirements
------------

Backend
~~~~~~~

* Python 2.7 (only tested with CPython)
* virtualenv (optional, but recommended)

Frontend
~~~~~~~~

* Sass_
* Node.js + NPM
* Bower (``npm install bower``)
* CoffeeScript (``npm install -g coffee-script``)
* UglifyJS2 (``npm install -g uglify-js``)
* importer (``npm install -g importer``)

.. _Sass: http://sass-lang.com/

Browser
~~~~~~~

Any web browser which `supports the HTML5 audio element`_ is supported.

.. _supports the HTML5 audio element: http://caniuse.com/audio

Instructions
------------

These instructions are similar to the quick installation in ``README.rst``.
This is meant as a supplement, so that the HTML5 frontend is installed
correctly.

.. code-block:: console

   $ git clone --recursive https://github.com/malept/gmusicprocurator.git
   $ cd gmusicprocurator
   $ bower install -p  # Added for frontend installation
   $ virtualenv venv  # Added for creating a separate virtualenv
   $ source venv/bin/activate
   (venv) $ pip install -r requirements.txt
   (venv) $ python -m gmusicprocurator list_devices --no-desktop
   # See quick install in README.rst
   (venv) $ python -m gmusicprocurator runserver
