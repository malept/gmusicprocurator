#!/usr/bin/env python
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
"""Flask(-Script) application runner."""

from __future__ import print_function

from flask_script import Manager
from functools import partial
from getpass import getpass
from gmusicprocurator.app import app, heapy
import sys

if heapy:
    import os
    import signal
    msg = 'Enabling memory profiler. Send SIGUSR1 to PID {0} for heap info'
    print(msg.format(os.getpid()), file=sys.stderr)

    def dump_memory_usage(signum, frame):
        """Signal handler: prints out heap object frequency table & exits."""
        print(heapy.heap())
        # At the moment, I can't figure out a way to handle a signal without
        # the socket server dying, so exit here.
        sys.exit(0)
    signal.signal(signal.SIGUSR1, dump_memory_usage)

manager = Manager(app)
if app.config['GMP_FRONTEND_ENABLED']:
    from flask_assets import ManageAssets
    from gmusicprocurator.app import assets
    manager.add_command('assets', ManageAssets(assets))


def error(msg):
    """Print an error message (prepended by ``ERROR: ``) to stderr."""
    print('ERROR: {0}'.format(msg), file=sys.stderr)

no_bool_option = partial(manager.option, action='store_false', default=True)


@no_bool_option('--no-desktop', dest='show_desktop', help='Hide desktop IDs')
@no_bool_option('--no-mobile', dest='show_mobile', help='Hide mobile IDs')
def list_devices(show_desktop, show_mobile):
    """
    List device IDs registered with Google Music.

    Defaults to showing both desktop and mobile IDs.
    """
    from gmusicapi.clients import Webclient
    from keyring import get_password
    webclient = Webclient()
    email = app.config['GACCOUNT_EMAIL']
    password = get_password('gmusicprocurator', email)
    if password is None:
        error('Password not set. Please run the set_password subcommand.')
        return
    success = webclient.login(email, password)
    if not success:
        error('Login failed.')
        return

    for device in webclient.get_registered_devices():
        dname = device['name'] if len(device['name']) > 0 else device['model']
        if not show_desktop and device['type'] == 'DESKTOP_APP':
            continue
        if not show_mobile and device['type'] == 'PHONE':
            continue
        print(u'* {dname} ({type}): {id}'.format(dname=dname, **device))


@manager.command
def set_password():
    """Set the Google account password."""
    import keyring
    password = None
    repeated = None
    while password is None or password != repeated:
        password = getpass('Please enter your password: ')
        repeated = getpass('Please verify your password: ')
        if password == repeated:
            keyring.set_password('gmusicprocurator',
                                 app.config['GACCOUNT_EMAIL'],
                                 password)
            print('Password set successfully.')
        else:
            error('Passwords do not match.')


def run():
    """Flask-Script convenience runner."""
    manager.run()

if __name__ == '__main__':
    run()
