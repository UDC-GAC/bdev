# Copyright (c) 2019 Universidade da Coruña
# Authors:
#     - Jonatan Enes [main](jonatan.enes@udc.es, jonatan.enes.alvarez@gmail.com)
#     - Roberto R. Expósito
#     - Juan Touriño
#
# This file is part of the BDWatchdog framework, from
# now on referred to as BDWatchdog.
#
# BDWatchdog is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.
#
# BDWatchdog is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with BDWatchdog. If not, see <http://www.gnu.org/licenses/>.


from __future__ import print_function

import os
import pwd
import datetime
import time
import sys


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def get_username(args):
    if not args or not args.username:
        return pwd.getpwuid(os.getuid())[0]
    else:
        return args.username


def get_timestamp(args):
    timestamp = None
    if args.time:
        try:
            ts = datetime.datetime.strptime(args.time, "%Y/%m/%d-%H:%M:%S")
            timestamp = int(time.mktime(ts.timetuple()))
        except ValueError:
            eprint("Bad time format, it should follow the format 'yyyy/mm/dd HH:MM:SS' (e.g., '2018/06/01-12:34:36')")
            exit(1)
    else:
        timestamp = int(time.time())
    return timestamp
