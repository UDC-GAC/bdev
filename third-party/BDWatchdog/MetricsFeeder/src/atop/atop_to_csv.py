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
import sys
import fileinput
import signal


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def sigterm_handler(_signo, _stack_frame):
    good_finish()


def good_finish():
    sys.stdout.flush()
    sys.exit(0)


def bad_finish(error):
    eprint("[ATOP TO CSV] error in : " + str(error))
    sys.exit(1)


signal.signal(signal.SIGTERM, sigterm_handler)


def process_line(line):
    return line.replace(" ", ",").strip()


def behave_like_pipeline():
    try:
        skip_lines = True
        for line in fileinput.input():
            # FIRST LINES RESTRICTOR
            if line == "SEP\n":
                skip_lines = False
                continue

            # MOST RESTRICTIVE FILTERS
            if line.endswith("n\n") or line.endswith("n 0\n") or skip_lines:
                continue

            print(process_line(line))
    except KeyboardInterrupt:
        # Exit silently
        good_finish()
    except IOError as e:
        bad_finish(e)


def main():
    behave_like_pipeline()


if __name__ == "__main__":
    main()
