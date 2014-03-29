This project is hosted at GitHub_. I gladly accept pull requests. Please make
sure your pull requests pass Travis CI, by running ``./run_tests.sh`` before
submission. Additionally, It would probably be in your best interests to add
yourself to the ``AUTHORS.rst`` file if you have not done so already.

.. _GitHub: https://github.com/malept/gmusicprocurator

A Vagrant_ environment is available for developing ``gmusicprocurator``. Run
the following command in the top-level source directory (once Vagrant
is installed):

.. code-block:: shell-session

    user@host:gmusicprocurator$ vagrant up

...and it will install all of the Python dependencies in a virtualenv_, and the
other dependencies (e.g., the node.js-based ones) globally. You can then log
into the virtual machine and install the package in develop mode:

.. code-block:: shell-session

    user@host:gmusicprocurator$ vagrant ssh
    # ...
    vagrant@vagrant:~$ source .virtualenv/bin/activate
    (.virtualenv)vagrant@vagrant:~$ pip install -e /vagrant

.. _Vagrant: https://www.vagrantup.com
.. _virtualenv: http://virtualenv.org/
