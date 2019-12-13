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

import socket
import sys


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def process_line(line):
    result_lines = list()
    in_fields = line.split(",")
    try:
        out_fields = in_fields[0:3]  # type,host,timestamp

        # Change the hostname as atop is unable to recognize properly hostnames with dots
        # e.g., jonatan.gac.dec.udc.es -> hostname is jonatan
        out_fields[1] = socket.gethostname()

        # RPOCESS INFO #
        if in_fields[0] == "PRM":
            out_fields.append(in_fields[6])  # pid
            out_fields.append(in_fields[7])  # command
            out_fields.append(in_fields[8])  # state
            out_fields.append(in_fields[10])  # virtual
            out_fields.append(in_fields[11])  # resident
        # out_fields.append(in_fields[20]) #swap
        if in_fields[0] == "PRC":
            out_fields.append(in_fields[5])  # time interval seconds
            out_fields.append(in_fields[6])  # pid
            out_fields.append(in_fields[7])  # command
            out_fields.append(in_fields[8])  # state
            out_fields.append(in_fields[10])  # system
            out_fields.append(in_fields[11])  # user
            out_fields.append(in_fields[17])  # sleep-average
        if in_fields[0] == "PRD":
            out_fields.append(in_fields[5])  # time interval seconds
            out_fields.append(in_fields[6])  # pid
            out_fields.append(in_fields[7])  # command
            out_fields.append(in_fields[8])  # state
            out_fields.append(in_fields[12])  # num sectors read
            out_fields.append(in_fields[14])  # num sectors written
        if in_fields[0] == "PRN":
            out_fields.append(in_fields[5])  # time interval seconds
            out_fields.append(in_fields[6])  # pid
            out_fields.append(in_fields[7])  # command
            out_fields.append(in_fields[8])  # state
            # out_fields.append(in_fields[9]) #module netatop loaded (y/n)
            out_fields.append(in_fields[10])  # num TCP packets out
            out_fields.append(in_fields[11])  # size of out TCP traffic
            out_fields.append(in_fields[12])  # num TCP packets in
            out_fields.append(in_fields[13])  # size of in TCP traffic
            out_fields.append(in_fields[14])  # num UDP packets out
            out_fields.append(in_fields[15])  # size of out UDP traffic
            out_fields.append(in_fields[16])  # num UDCP  packets in
            out_fields.append(in_fields[17])  # size of in UDP  traffic

        # SYSTEM INFO #
        if in_fields[0] == "cpu":
            out_fields.append(in_fields[5])  # time interval seconds
            out_fields.append(in_fields[6])  # ticks per second
            out_fields.append(in_fields[7])  # cpu-core
            out_fields.append(in_fields[8])  # system
            out_fields.append(in_fields[9])  # user
            out_fields.append(in_fields[10])  # irq
            out_fields.append(in_fields[11])  # idle
            out_fields.append(in_fields[12])  # wait
        if in_fields[0] == "DSK":
            out_fields.append(in_fields[5])  # time interval seconds
            out_fields.append(in_fields[6])  # disk resource
            out_fields.append(in_fields[7])  # time spent resolving
            out_fields.append(in_fields[8])  # read requests
            out_fields.append(in_fields[9])  # read sectors
            out_fields.append(in_fields[10])  # write request
            out_fields.append(in_fields[11])  # write sectors
        if in_fields[0] == "CPU":
            out_fields.append(in_fields[5])  # time interval seconds
            out_fields.append(in_fields[6])  # ticks per second
            out_fields.append(in_fields[7])  # num-cores
            out_fields.append(in_fields[8])  # system
            out_fields.append(in_fields[9])  # user
            out_fields.append(in_fields[10])  # user niced or ?
            out_fields.append(in_fields[11])  # idle
            out_fields.append(in_fields[12])  # wait
            out_fields.append(in_fields[12])  # irq
            out_fields.append(in_fields[12])  # softirq
        if in_fields[0] == "MEM":
            # out_fields.append(in_fields[5]) #time interval seconds
            out_fields.append(in_fields[6])  # page size
            out_fields.append(in_fields[7])  # pages of physical memory
            out_fields.append(in_fields[8])  # pages of free memory
            # out_fields.append(in_fields[9]) #pages of page cache
            # out_fields.append(in_fields[10]) #pages of buffer cache
            # out_fields.append(in_fields[11]) #pages of slab
            # out_fields.append(in_fields[12]) #pages of dirty pages
            # out_fields.append(in_fields[13]) #pages of reclaimable slab
            # out_fields.append(in_fields[14]) #pages of vmware ballon
            # out_fields.append(in_fields[15]) #pages of shared memory
            # out_fields.append(in_fields[16]) #pages of resident shared memory
            # out_fields.append(in_fields[17]) #pages of swapped shared memory
            # out_fields.append(in_fields[18]) #huge page size
            # out_fields.append(in_fields[19]) #total size of huge pages
            # out_fields.append(in_fields[20]) #total size of free huge pages
        if in_fields[0] == "SWP":
            # out_fields.append(in_fields[5]) #time interval seconds
            out_fields.append(in_fields[6])  # page size
            out_fields.append(in_fields[7])  # swap size in pages
            out_fields.append(in_fields[8])  # free swap space in pages

        # NET lines differ from length because the upper interface represents transport and network, while the
        # other lines are one per interface, UNIFY!!!
        if in_fields[0] == "NET":

            device = in_fields[6]
            if device == "upper":
                # Upper layer, transport (TCP) and network (IP)
                # Create two "interfaces" from this line

                # TRANSPORT
                out_fields = in_fields[0:3]  # type,host,timestamp
                out_fields.append(in_fields[5])  # time interval seconds

                out_fields.append("transport")  # net device
                out_fields.append(str(int(in_fields[7]) + int(in_fields[9])))  # packets in adding TCP and UDP
                out_fields.append(
                    "1")  # always -1, used for length purposes (bytes in, doesn't apply for upper layer)
                out_fields.append(str(int(in_fields[8]) + int(in_fields[10])))  # packets out adding TCP and UDP
                out_fields.append(
                    "1")  # always -1, used for length purposes (bytes out, doesn't apply for upper layer)

                out_fields.append(
                    "1")  # always -1, used for length purposes (interface speed, doesn't apply for upper layer)
                out_fields.append(
                    "1")  # always -1, used for length purposes (interface mode, doesn't apply for upper layer)
                result_lines.append(str(",".join(out_fields)).strip())

                # NETWORK
                out_fields = in_fields[0:3]  # type,host,timestamp
                out_fields.append(in_fields[5])  # time interval seconds

                out_fields.append("network")  # net device
                out_fields.append(in_fields[11])  # packets in
                out_fields.append(
                    "1")  # always -1, used for length purposes (bytes in, doesn't apply for upper layer)
                out_fields.append(in_fields[12])  # packets out
                out_fields.append(
                    "1")  # always -1, used for length purposes (bytes out, doesn't apply for upper layer)

                out_fields.append(
                    "1")  # always -1, used for length purposes (interface speed, doesn't apply for upper layer)
                out_fields.append(
                    "1")  # always -1, used for length purposes (interface mode, doesn't apply for upper layer)
                result_lines.append(str(",".join(out_fields)).strip())

                return result_lines

            else:
                out_fields.append(in_fields[5])  # time interval seconds

                out_fields.append(in_fields[6])  # net device

                out_fields.append(in_fields[7])  # packets in
                out_fields.append(in_fields[8])  # bytes in

                out_fields.append(in_fields[9])  # packets out
                out_fields.append(in_fields[10])  # bytes out

                out_fields.append(in_fields[11])  # interface speed
                out_fields.append(in_fields[12])  # duplex mode 0 -> half, 1 -> full

        if in_fields[0] == "INFINIBAND":
            out_fields.append(in_fields[3])  # time interval in seconds
            out_fields.append(in_fields[4])  # device
            out_fields.append(in_fields[5])  # port
            out_fields.append(in_fields[6])  # counter for received 'data octets'
            out_fields.append(in_fields[7])  # counter for sent 'data octets'
        # All fields are valid

        result_lines.append(str(",".join(out_fields)).strip())
        return result_lines
    except IndexError:
        eprint("[FIELD FILTER] Line discarded, number of fields incorrect: " + line)


def behave_like_pipeline():
    try:
        # for line in fileinput.input():
        while True:
            line = sys.stdin.readline()
            for result in process_line(line):
                print(result)
    except (KeyboardInterrupt, IOError):
        # Exit silently
        pass
    except Exception as e:
        eprint("[FIELD FILTER] error: " + str(e))


def main():
    behave_like_pipeline()


if __name__ == "__main__":
    main()
