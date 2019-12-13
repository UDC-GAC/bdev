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
    fields = line.split(",")

    # PROCESS INFO #
    if fields[0] == "PRC":
        time_interval_seconds = int(fields[3])
        fields[7] = str(format(1.0 * int(fields[7]) / time_interval_seconds, '.2f'))  # User
        fields[8] = str(format(1.0 * int(fields[8]) / time_interval_seconds, '.2f'))  # Kernel
        fields[9] = str(format(1.0 * int(fields[9]) / time_interval_seconds, '.2f'))  # Sleep
    if fields[0] == "PRM":
        fields[6] = str(format(int(fields[6]) / 1024.0, '.2f'))  # Virtual Memory
        fields[7] = str(format(int(fields[7]) / 1024.0, '.2f'))  # Resident Memory
        # fields[8] = str(format(int(fields[8]) / 1024.0, '.2f')) #Swap Memory
    if fields[0] == "PRD":
        time_interval = int(fields[3])
        fields[7] = str(format(int(fields[7]) * 512.0 / (time_interval * 1048576.0), '.2f'))  # Bandwidth Read
        fields[8] = str(format(int(fields[8]) * 512.0 / (time_interval * 1048576.0), '.2f'))  # Bandwidth Write
    if fields[0] == "PRN":
        time_interval = int(fields[3])
        fields[8] = str(
            format((int(fields[8]) * 8) / (time_interval * 1048576.0), '.2f'))  # Bandwidth out TCP in Mbps
        fields[10] = str(
            format((int(fields[10]) * 8) / (time_interval * 1048576.0), '.2f'))  # Bandwidth in TCP in Mbps
        fields[12] = str(
            format((int(fields[12]) * 8) / (time_interval * 1048576.0), '.2f'))  # Bandwidth out UDP in Mbps
        fields[14] = str(
            format((int(fields[14]) * 8) / (time_interval * 1048576.0), '.2f'))  # Bandwidth in UDP in Mbps
    if fields[0] == "NETHOGS":
        time_interval = int(fields[3])
        fields[7] = str(format(float(fields[7]) * 8 / time_interval, '.2f'))  # Bandwidth out in Mbps
        fields[8] = str(format(float(fields[8]) * 8 / time_interval, '.2f'))  # Bandwidth in Mbps

    # SYSTEM INFO #
    if fields[0] == "CPU":
        time_interval_seconds = int(fields[3])
        cpu_tick_per_second = int(fields[4])
        num_cpus = int(fields[5])

        total_time_spent = int(fields[6]) + int(fields[7]) + int(fields[8]) + int(fields[10])
        # system + user + user niced + wait

        usage = str(
            format(100.0 * total_time_spent / (num_cpus * cpu_tick_per_second * time_interval_seconds), '.2f'))
        fields.append(usage)

    if fields[0] == "cpu":
        time_interval_seconds = int(fields[3])
        cpu_tick_per_second = int(fields[4])
        total_ticks = time_interval_seconds * cpu_tick_per_second
        fields[6] = str(format(int(fields[6]) * 100.0 / total_ticks, '.2f'))  # kernel

        tmp_f7 = int(fields[7]) * 100.0 / total_ticks
        tmp_f8 = int(fields[8]) * 100.0 / total_ticks

        fields[7] = str(format(tmp_f7, '.2f'))  # user
        fields[8] = str(format(tmp_f7 + tmp_f8, '.2f'))  # Add the two users

        fields[9] = str(format(int(fields[9]) * 100.0 / total_ticks, '.2f'))  # idle
        fields[10] = str(format(int(fields[10]) * 100.0 / total_ticks, '.2f'))  # wait
    if fields[0] == "DSK":
        time_interval = int(fields[3])
        time_spent_resolving_miliseconds = int(fields[5])
        fields[5] = str(
            format(100.0 * time_spent_resolving_miliseconds / (time_interval * 1000), '.2f'))  # Disk usage in %
        fields[7] = str(format(int(fields[7]) * 512.0 / (time_interval * 1048576.0), '.2f'))  # Bandwidth Read
        fields[9] = str(format(int(fields[9]) * 512.0 / (time_interval * 1048576.0), '.2f'))  # Bandwidth Write
    if fields[0] == "MEM":
        page_size = int(fields[3])
        fields[4] = str(format(page_size * int(fields[4]) / 1048576.0, '.2f'))  # total memory
        fields[5] = str(format(page_size * int(fields[5]) / 1048576.0, '.2f'))  # free memory
        usage = str(format(100.0 * (1 - float(fields[5]) / float(fields[4])), '.2f'))
        fields.append(usage)
    if fields[0] == "SWP":
        page_size = int(fields[3])
        fields[4] = str(format(page_size * int(fields[4]) / 1048576.0, '.2f'))  # total swap
        fields[5] = str(format(page_size * int(fields[5]) / 1048576.0, '.2f'))  # free swap
    if fields[0] == "NET":
        time_interval = int(fields[3])
        interface_speed = int(fields[9])  # / 8.0 # Convert from Mbps to MBps
        interface_mode = int(fields[10])  # 0 -> half, 1 -> full
        fields[6] = str(format((int(fields[6]) * 8) / (time_interval * 1048576.0), '.2f'))  # Bandwidth in in Mbps
        fields[8] = str(format((int(fields[8]) * 8) / (time_interval * 1048576.0), '.2f'))  # Bandwidth out in Mbps

        if interface_mode == 0 and float(interface_speed) > 0:
            # Half duplex
            total_bandwidth = float(fields[6]) + float(fields[8])
            fields[9] = str(format(100.0 * total_bandwidth / interface_speed, '.2f'))
        elif interface_mode == 1 and float(interface_speed) > 0:
            # Full duplex
            total_bandwidth = float(fields[6]) + float(fields[8])
            fields[9] = str(format(100.0 * total_bandwidth / (2 * interface_speed), '.2f'))
        else:
            # Other, transport, network or loopback "devices"
            pass

    if fields[0] == "INFINIBAND":
        time_interval = int(fields[3])
        fields[6] = str(format((int(fields[6]) * 4) / (time_interval * 1048576.0), '.2f'))  # Bandwidth in in Mbps
        fields[7] = str(format((int(fields[7]) * 4) / (time_interval * 1048576.0), '.2f'))  # Bandwidth out in Mbps

    return str(",".join(fields)).replace("\n", "")


def behave_like_pipeline():
    try:
        # for line in fileinput.input():
        while True:
            line = sys.stdin.readline().rstrip('\n')
            # If code is changed back to a for loop, remove the rstrip part
            print(process_line(line))
    except (KeyboardInterrupt, IOError):
        # Exit silently
        pass
    except Exception as e:
        eprint("[FIELD TRANSLATOR] error : " + str(e))


def main():
    behave_like_pipeline()


if __name__ == "__main__":
    main()
