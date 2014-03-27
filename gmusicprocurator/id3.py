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

from mutagen.id3 import APIC
from mutagen.easyid3 import EasyID3
from mutagen.mp3 import EasyMP3
import requests

ENCODING_UTF8 = 3
TYPE_COVER_FRONT = 3


def set_albumart(id3, key, urls):
    '''
    Originally from https://stackoverflow.com/q/14369366
    '''
    for url in urls:
        response = requests.get(url)
        tag = APIC(encoding=ENCODING_UTF8,
                   mime=response.headers['Content-Type'],
                   type=TYPE_COVER_FRONT, desc=u'Cover', data=response.content)
        id3.add(tag)

EasyID3.RegisterKey('albumart', setter=set_albumart)

__all__ = ['EasyMP3']
