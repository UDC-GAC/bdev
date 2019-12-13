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
import fileinput
import signal
import time
import traceback

from MetricsFeeder.src.pipelines import csv_to_json
from MetricsFeeder.src.pipelines.csv_to_json import process_line as to_json
from MetricsFeeder.src.pipelines.json_to_TSDB_json import process_line as to_TSDB_json

metrics_dict, tags_dict, template = None, None, None
header_mapping = dict()


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def sigterm_handler(_signo, _stack_frame):
    good_finish()


def good_finish():
    sys.stdout.flush()
    sys.exit(0)


def bad_finish():
    sys.exit(1)


def get_hostname():
    return socket.gethostname()


def get_timestamp():
    return int(time.time())


def create_header_mapping(header):
    mapping = dict()
    fs = header.split(",")
    counter = 0
    for f in fs:
        mapping[f] = counter
        counter += 1
    return mapping


signal.signal(signal.SIGTERM, sigterm_handler)


def turbostat_to_csv(line, header_mapping, fields):
    if not line:
        eprint("Empty line")
        return

    # Skip header by looking for it and avoiding it
    try:
        # Try to test for string values for different versions of turbostat
        # if fields[0] == "Core" or fields[0] == "Package" or fields[0] == "usec":
        #    continue

        # Try to cast the average Megahertz, which has an int value for all the lines to be processed
        int(fields[header_mapping["Avg_MHz"]])

    except ValueError:
        # Line is header, skip
        return
    except IndexError:
        # Line is ?
        eprint("Error with line:" + line)
        return

    try:
        if fields[header_mapping["CPU"]] == "-":
            # line is for entire system
            return ("SYS_PWR" + "," + get_hostname() + "," + str(get_timestamp()) + "," + fields[
                header_mapping["Core"]] + "," + fields[header_mapping["PkgTmp"]] + "," + fields[
                        header_mapping["PkgWatt"]])
        else:
            if len(fields) >= header_mapping["PkgWatt"]:
                # line is for package, because turbostat aggregates and joins first core
                # and package, print also core
                if "Package" in header_mapping:
                    return ("PKG_PWR" + "," + get_hostname() + "," + str(get_timestamp()) + "," + fields[
                        header_mapping["Package"]] + "," + fields[header_mapping["PkgTmp"]] + "," + fields[
                                header_mapping["PkgWatt"]])

                else:
                    # Host may only have one package and turbostat may not report the Package field
                    return ("PKG_PWR" + "," + get_hostname() + "," + str(get_timestamp()) + "," + fields[
                        header_mapping["Core"]] + "," + fields[header_mapping["PkgTmp"]] + "," + fields[
                                header_mapping["PkgWatt"]])

    except IndexError:
        eprint("Line : '" + line.strip() + "' couldn't be parsed")
        return


def process_line(line):
    fields = line.split(",")
    line_in_csv = turbostat_to_csv(line, header_mapping, fields)
    if line_in_csv:
        json_docs = to_json(line_in_csv, metrics_dict, tags_dict, template)
        if json_docs:
            for doc in json_docs:
                line_in_valid_json = to_TSDB_json(doc)
                print(line_in_valid_json)


def process_header(line):
    # required_fields = ["PkgWatt", "CorWatt", "Core", "CPU"]
    required_fields = ["PkgWatt", "Core", "CPU"]
    header_mapping = create_header_mapping(line.strip())
    eprint("HEADER MAPPING to be used is:" + str(header_mapping))
    for field in required_fields:
        if field not in header_mapping:
            eprint("Field " + field + " not present in output, can't continue")
            bad_finish()
    return header_mapping


def behave_like_pipeline():
    global header_mapping

    try:
        header_was_processed = False

        for line in fileinput.input():
            # Process header and adapt pipe, after that header will be skipped
            if not header_was_processed:
                header_mapping = process_header(line)
                header_was_processed = True
            # Process line
            else:
                process_line(line)

    except KeyboardInterrupt:
        good_finish()
    except Exception as error:
        eprint("[TURBOSTAT TO CSV] error : " + str(error) + str(traceback.format_exc()))


def main():
    global metrics_dict, tags_dict, template
    metrics_dict, tags_dict, template = csv_to_json.initialize()
    behave_like_pipeline()


if __name__ == "__main__":
    main()
