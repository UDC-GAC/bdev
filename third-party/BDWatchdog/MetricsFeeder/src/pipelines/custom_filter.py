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


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def process_line(line):
    in_fields = line.split(",")

    # Use this filter to drop processes of kernel OS when the -a atop option is present
    if in_fields[0] in ["PRC", "PRN", "PRM"]:
        if any(command in in_fields[5] for command in
               ["(kworker)", "(systemd)", "(migration)", "(rcu)", "(ksoftirq)", "(bioset)"]):
            return

    # FIX for very high disk values of terminal process probably due to pseudo writes of the use of pipelines
    if in_fields[0] == "PRD":
        if any(command in in_fields[5] for command in
               ["(nethogs), (python), (kworker)", "(migration)", "(rcu)",
                "(ksoftirq)", "(bash)", "(bioset)", "(sshd)", "(ssh)"]):
            return
    return line.strip()


def behave_like_pipeline():
    try:
        # for line in fileinput.input():
        while True:
            line = sys.stdin.readline()
            result = process_line(line)
            if result:
                print(result)
    except (KeyboardInterrupt, IOError):
        # Exit silently
        pass
    except Exception as error:
        eprint("[CUSTOM FILTER] error : " + str(error))


def main():
    behave_like_pipeline()


if __name__ == "__main__":
    main()
