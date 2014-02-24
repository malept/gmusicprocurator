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

Create a config file in ``~/.config/gmusicprocurator.cfg`` that looks like
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
   $ python -m gmusicprocurator
