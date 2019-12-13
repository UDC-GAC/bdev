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
import pwd
import subprocess
import socket
import signal

timestamp = 0
interval = 0


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
    global timestamp
    global interval
    if line.startswith("TIMESTAMP:"):
        timestamp = int(line.strip().split(":")[1])
        return None
    if line.startswith("INTERVAL:"):
        interval = int(line.strip().split(":")[1])
        return None
    if line == "\n" or line == "" or line.startswith("END") or line.startswith("START"):
        return None

    try:
        fields = line.split()
        command_string = ''.join(fields[0:len(fields) - 2])
        out_bandwidth = float(fields[-2])
        in_bandwidth = float(fields[-1])
        fields = command_string.split("/")
        uid = int(fields[-1])
        username = pwd.getpwuid(uid).pw_name
        pid = int(fields[-2])
    except (IndexError, ValueError):
        return None

    if pid == 0:
        return None

    try:
        result = subprocess.check_output(['ps', '-p', str(pid), '-o', 'comm='])
    except subprocess.CalledProcessError:
        return None
    command = "(" + result.decode().strip() + ")"
    hostname = socket.gethostname()
    header = "NETHOGS"

    return (header + "," + hostname + "," + str(timestamp) + "," + str(
        interval) + "," + username + "," + command + "," + str(pid) + "," + str(
        out_bandwidth) + "," + str(in_bandwidth))


def behave_like_pipeline():
    try:
        # for line in fileinput.input():
        while True:
            line = sys.stdin.readline()
            try:
                result = process_line(line)
                if result:
                    print(result)
            except (KeyboardInterrupt, IOError):
                # Exit silently
                pass
            except Exception as e:
                eprint("ERROR in line '" + line.strip() + "'")
                eprint(e)
    except KeyboardInterrupt:
        # Exit silently
        good_finish()
    except IOError as e:
        bad_finish(e)


def main():
    behave_like_pipeline()


if __name__ == "__main__":
    main()
