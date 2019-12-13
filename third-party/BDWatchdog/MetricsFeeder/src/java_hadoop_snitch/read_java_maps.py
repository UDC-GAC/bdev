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

import pickle
import os
import socket
from MetricsFeeder.src.java_hadoop_snitch.java_snitch import process_files

_base_path = os.path.dirname(os.path.abspath(__file__))
VAR_JAVA_MAPPINGS_FOLDER = "JAVA_MAPPINGS_FOLDER_PATH"
DEFAULT_JAVA_MAPPINGS_FOLDER = "java_mappings"

java_mappings_folder_path = os.getenv(VAR_JAVA_MAPPINGS_FOLDER, os.path.join(_base_path, DEFAULT_JAVA_MAPPINGS_FOLDER))


def get_filepath(process_name):
    return "{0}/{1}.{2}.p".format(java_mappings_folder_path, process_name, socket.gethostname())

def main():
    for process_name in process_files:
        try:
            filename = get_filepath(process_name)
            with open(filename, 'rb') as fp:
                itemlist = pickle.load(fp)
            print(process_name + "->" + str([int(x) for x in itemlist]))
        except (IOError, EOFError):
            pass


if __name__ == "__main__":
    main()
