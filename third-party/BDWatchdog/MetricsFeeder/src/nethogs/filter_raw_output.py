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


import fileinput


def main():
    first_batch_processed = False
    in_second_batch = False
    for line in fileinput.input():
        if line.startswith("START") or line.startswith("TIMESTAMP") \
                or line.startswith("INTERVAL"):
            print(line.strip())

        elif line.startswith("Refreshing:"):
            if not first_batch_processed:
                first_batch_processed = True
            else:
                in_second_batch = True
        elif line.startswith("END"):
            first_batch_processed = False
            in_second_batch = False
        else:
            if in_second_batch:
                print(line.strip())


if __name__ == "__main__":
    main()
