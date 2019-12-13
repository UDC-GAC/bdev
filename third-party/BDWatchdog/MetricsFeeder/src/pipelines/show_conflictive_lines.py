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
import re


def main():
    skip_lines = True
    for line in fileinput.input():
        ## LINES FILTERED UNTIL NOT FIRST SEP APPEARS
        line = re.sub('\s+', ' ', line)
        m = re.search(r"\(([A-Za-z0-9_,:/\s]+)\)", line)
        if (m is not None):
            matched = m.group(1)
            pat_list = re.findall("[A-Za-z0-9_,:/]+", matched)
        if len(pat_list) > 1:
            print(line)


if __name__ == "__main__":
    main()
