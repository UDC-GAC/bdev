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
import socket
import subprocess
import time
import pickle
import os
import errno

_base_path = os.path.dirname(os.path.abspath(__file__))
VAR_JAVA_MAPPINGS_FOLDER = "JAVA_MAPPINGS_FOLDER_PATH"
DEFAULT_JAVA_MAPPINGS_FOLDER = "java_mappings"
VAR_JAVA_SNITCH_POLLING_SECONDS = "JAVA_SNITCH_POLLING_SECONDS"
DEFAULT_JAVA_SNITCH_POLLING_SECONDS = 3
VAR_JAVA_SNITCH_TIME_TO_DUMP = "JAVA_SNITCH_TIME_TO_DUMP_COUNTER_MAX"
DEFAULT_JAVA_SNITCH_TIME_TO_DUMP = 2

java_mappings_folder_path = os.getenv(VAR_JAVA_MAPPINGS_FOLDER, os.path.join(_base_path, DEFAULT_JAVA_MAPPINGS_FOLDER))
java_snitch_polling_seconds = int(os.getenv(VAR_JAVA_SNITCH_POLLING_SECONDS, DEFAULT_JAVA_SNITCH_POLLING_SECONDS))
time_to_dump_counter_max = int(os.getenv(VAR_JAVA_SNITCH_TIME_TO_DUMP, DEFAULT_JAVA_SNITCH_TIME_TO_DUMP))

process_names = ["NameNode", "SecondaryNameNode", "DataNode", "ResourceManager", "NodeManager", "YarnChild",
                 "MRAppMaster", "CoarseGrainedExecutorBackend"]
process_files = ["NameNode", "SecondaryNameNode", "DataNode", "ResourceManager", "NodeManager", "YarnChild",
                 "MRAppMaster", "CoarseGrainedExecutorBackend", "OTHER"]


def get_filepath(process_name):
    return "{0}/{1}.{2}.p".format(java_mappings_folder_path, process_name, socket.gethostname())


def run_command(c):
    """given shell command, returns communication tuple of stdout and stderr"""
    return subprocess.Popen(c,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            stdin=subprocess.PIPE).communicate()


def check_path_existence_and_create(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise


def read_process_pids_from_file(process_name):
    try:
        filename = get_filepath(process_name)
        with open(filename, 'rb') as content_file:
            itemlist = pickle.load(content_file)
        return [int(x) for x in itemlist]
    except (IOError, EOFError):
        return []


def dump_process_pids_to_file(process_name, pidlist):
    try:
        filename = get_filepath(process_name)
        with open(filename, 'wb') as f1:
            pickle.dump([int(x) for x in pidlist], f1)
    except IOError:
        # mapping folder doesn't exist, create it for next time
        check_path_existence_and_create(java_mappings_folder_path)


def read_all():
    proc_dict = dict()
    for proc_file in process_files:
        pids = read_process_pids_from_file(proc_file)
        proc_dict[proc_file] = pids
    return proc_dict


def process_line(line):
    fields = line.strip().split(" ")
    pid = fields[0]
    for field in fields:
        if field.startswith("org.apache.hadoop.") or field.startswith("org.apache.spark."):
            return pid + " " + field.strip().split(".")[-1]


def merge_lists(l1, l2):
    return list(set(l1 + l2))


def merge_dicts(dict1, dict2):
    # print "Merging dictionaries"
    # print "Dict 1 is: " + str(dict1)
    # print "Dict 2 is: " + str(dict2)
    for key in dict2:
        try:
            dict1[key] = merge_lists(dict1[key], dict2[key])
        except KeyError:
            dict1[key] = dict2[key]
    # print "New dict is " + str(dict1)
    return dict1


def dump_all(java_dict):
    existing_data = read_all()
    java_dict = merge_dicts(java_dict, existing_data)
    print("Dumping dictionaries " + str(java_dict))
    for key in java_dict:
        dump_process_pids_to_file(key, java_dict[key])


def run_ps():
    lines = list()
    cmd = ["ps", "h", "-eo", "pid,cmd"]
    ps = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    while True:
        line = ps.stdout.readline()
        if line == b'' and ps.poll() is not None:
            break
        lines.append(line.decode('utf-8').strip("\n"))
    output = ps.communicate()[0]
    return lines


def remove_files():
    for process_name in process_files:
        try:
            filename = get_filepath(process_name)
            os.remove(filename)
        except (IOError, EOFError):
            pass


def main():
    time_to_dump_counter = 0
    print("[HADOOP JAVA SNITCH] Going to monitor hadoop java process every '" + str(
        java_snitch_polling_seconds) + "' seconds dumping every '" + str(
        java_snitch_polling_seconds * time_to_dump_counter_max) + "' seconds")

    java_proc_dict = dict()
    remove_files()
    while True:
        try:
            lines = run_ps()
            for line in lines:
                line = process_line(line)
                if not line or line == "":
                    continue
                pid_command = line.split(" ")
                pid, command = pid_command[0], pid_command[1]

                if command.strip() in process_names:
                    proc_dict_key = command
                else:
                    proc_dict_key = "OTHER"

                try:
                    java_proc_dict[proc_dict_key].append(int(pid))
                except KeyError:
                    java_proc_dict[proc_dict_key] = [int(pid)]

            time_to_dump_counter += 1

            time.sleep(java_snitch_polling_seconds)

            if time_to_dump_counter >= time_to_dump_counter_max:
                time_to_dump_counter = 0
                dump_all(java_proc_dict)
                java_proc_dict = dict()

        except KeyboardInterrupt:
            dump_all(java_proc_dict)
            exit(0)


if __name__ == "__main__":
    main()
