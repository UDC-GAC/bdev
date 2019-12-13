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


import sys


def process_line(line):
    in_fields = line.split(",")

    # Let always a single process through so as to give always at least one metric for process-based monitoring,
    # otherwise if there are no usages they will be all filtered out by the value filter (due to too low values)
    # thus giving the impression of non-usage
    command = in_fields[5]
    if command == "(systemd)":
        return line.strip()

    if in_fields[0] == "PRM":
        if float(in_fields[6]) < 10.0:
            return  # virtual
        if float(in_fields[7]) < 10.0:
            return  # resident
    if in_fields[0] == "PRC":
        if float(in_fields[7]) + float(in_fields[8]) + float(in_fields[9]) < 0.05:
            return  # sys + user + wait
    if in_fields[0] == "PRD":
        if float(in_fields[7]) + float(in_fields[8]) < 0.05:
            return  # MB read + write bandwidth
    if in_fields[0] == "PRN":
        if int(in_fields[7]) + int(in_fields[9]) + int(in_fields[11]) + int(in_fields[13]) < 30:
            return  # TCP and UDP packets in and out
        if float(in_fields[8]) + float(in_fields[10]) + float(in_fields[12]) + float(in_fields[14]) < 0.05:
            return  # TCP and UDP MB bandwidths in and out
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


def main():
    behave_like_pipeline()


if __name__ == "__main__":
    main()
