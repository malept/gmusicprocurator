This project is hosted at GitHub_. I gladly accept both issues and pull
requests.

.. _GitHub: https://github.com/malept/gmusicprocurator

Filing Issues
-------------

Issues include bugs, feedback, and feature requests. Before you file a new
issue, please make sure that your issue has not already been filed by someone
else. In addition to the GitHub issues UI, a `kanban board`_ is available to
provide a way to show the relative priority and status of open issues.

.. _kanban board: https://huboard.com/malept/gmusicprocurator

When filing a bug, please include the following information:

* Operating system. If on Linux, please also include the distribution name and
  version.
* Python version that is running GMusicProcurator, by running ``python -V``.
* Installed Python packages, by running ``pip freeze``.
* Any relevant app settings.
* A detailed list of steps to reproduce the bug.
* If the bug is a Python exception, the traceback will be very helpful.
* If the bug is related to the frontend, a screenshot will be helpful, along
  with the browser name and version that is being used.

Pull Requests
-------------

Please make sure your pull requests pass the continuous integration suite, by
running ``tox`` before creating your submission. (Run ``pip install tox`` if
it's not already installed.) The CI suite is also automatically run for every
pull request, but at this time it's faster to run it locally. Additionally,
it would probably be in your best interests to add yourself to the
``AUTHORS.rst`` file if you have not done so already.

When you submit your PR, if you have changed CoffeeScript files, `Hound CI`_
will make comments about its conformity to the code style guide as described in
the `.coffeelint.json` file in the top level of the repository.

.. _Hound CI: https://houndci.com/

Development Environment
-----------------------

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
