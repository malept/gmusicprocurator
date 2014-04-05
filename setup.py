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

####
# Dirty Monkeypatching Hacks
####

# distutils sdist for Vagrant
#
# Allow distutils sdist to work correctly when using Vagrant + VirtualBox
# shared folders, where hard links are not implemented.
#
# See also: http://bugs.python.org/msg208792

import os
import sys

if 'sdist' in sys.argv and os.environ.get('USER', '') == 'vagrant':
    if hasattr(os, 'link'):
        del os.link

# distutils check ReST + pygments
#
# When the long description contains a code block, the distutils ``check -r``
# will fail because the default options do not include ``syntax_highlight``.
# Monkeypatch ``docutils.frontend.OptionParser`` to provide a default for
# this option.

if 'check' in sys.argv:
    try:
        from docutils.frontend import OptionParser
    except ImportError:
        pass  # docutils isn't installed, ignore
    else:
        OptionParser.settings_defaults['syntax_highlight'] = None

####
# Your regularly scheduled setup file
####

import json
import re
from setuptools import find_packages, setup

GPL3PLUS = 'License :: OSI Approved :: ' \
           'GNU General Public License v3 or later (GPLv3+)',
CLASSIFIERS = [
    'Development Status :: 4 - Beta',
    'Framework :: Flask',
    GPL3PLUS,
    'Operating System :: POSIX',
    'Programming Language :: Python :: 2',
    'Programming Language :: Python :: 2.7',
]

RE_REQ_COMMENT = re.compile(r'#.*$')


def requires_from_req_txt(filename):
    requires = []
    with open(filename) as f:
        for line in f:
            req = RE_REQ_COMMENT.sub('', line).strip()
            if req != '' and '://' not in req:
                if req.startswith('-r '):
                    requires += requires_from_req_txt(req[3:])
                else:
                    requires.append(req)
    return requires

with open('bower.json') as f:
    metadata = json.load(f)

with open('README.rst') as f:
    long_description = f.read()

requires = requires_from_req_txt('requirements.txt')

attrs = {
    'name': metadata['name'],
    'version': metadata['version'],
    'description': metadata['description'],
    'long_description': long_description,
    'author': metadata['authors'][0],
    'author_email': 'gmusicprocurator.no.spam@lazymalevolence.com',
    'url': metadata['homepage'],
    'packages': find_packages(),
    'include_package_data': True,
    'zip_safe': False,
    'entry_points': {
        'console_scripts': [
            'gmusicprocurator = gmusicprocurator.__main__:run',
        ],
    },
    'install_requires': requires,
    'classifiers': CLASSIFIERS,
}

setup(**attrs)
