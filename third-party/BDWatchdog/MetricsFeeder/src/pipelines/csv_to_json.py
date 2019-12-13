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
import os
import fileinput

TEMPLATE_PATH = "TEMPLATE_PATH"
METRICS_PATH = "METRICS_PATH"
TAGS_PATH = "TAGS_PATH"

template_path = os.getenv(TEMPLATE_PATH, "./src/pipelines/templates/")
metrics_path = os.getenv(METRICS_PATH, "./src/pipelines/metrics/")
tags_path = os.getenv(TAGS_PATH, "./src/pipelines/tags/")


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def initialize():
    # BASIC TEMPLATE
    with open(os.path.join(template_path, "template.json"), "r") as myfile:
        template = myfile.read().replace('\n', '').replace('\t', '')

    metrics_files = {
        "cpu": metrics_path + "cpu.txt",
        "CPU": metrics_path + "CPU.txt",
        "MEM": metrics_path + "MEM.txt",
        "SWP": metrics_path + "SWP.txt",
        "DSK": metrics_path + "DSK.txt",
        "NET": metrics_path + "NET.txt",
        "PRC": metrics_path + "PRC.txt",
        "PRM": metrics_path + "PRM.txt",
        "PRD": metrics_path + "PRD.txt",
        "PRN": metrics_path + "PRN.txt",
        "INFINIBAND": metrics_path + "INFINIBAND.txt",
        "NETHOGS": metrics_path + "NETHOGS.txt",
        "SYS_PWR": metrics_path + "SYS_PWR.txt",
        "PKG_PWR": metrics_path + "PKG_PWR.txt",
        "CORE_PWR": metrics_path + "CORE_PWR.txt"
    }

    tags_files = {
        "cpu": tags_path + "cpu.txt",
        "CPU": tags_path + "CPU.txt",
        "MEM": tags_path + "MEM.txt",
        "SWP": tags_path + "SWP.txt",
        "DSK": tags_path + "DSK.txt",
        "NET": tags_path + "NET.txt",
        "PRC": tags_path + "PRC.txt",
        "PRM": tags_path + "PRM.txt",
        "PRD": tags_path + "PRD.txt",
        "PRN": tags_path + "PRN.txt",
        "INFINIBAND": tags_path + "INFINIBAND.txt",
        "NETHOGS": tags_path + "NETHOGS.txt",
        "SYS_PWR": tags_path + "SYS_PWR.txt",
        "PKG_PWR": tags_path + "PKG_PWR.txt",
        "CORE_PWR": tags_path + "CORE_PWR.txt",
    }

    metrics = ["cpu", "CPU", "MEM", "SWP", "DSK", "NET", "PRC", "PRM", "PRD", "PRN", "NETHOGS", "INFINIBAND", "SYS_PWR",
               "PKG_PWR", "CORE_PWR"]

    metrics_dict = dict()
    tags_dict = dict()

    for metric in metrics:
        with open(metrics_files[metric], "r") as myfile:
            metrics_dict[metric] = myfile.read().replace('\n', '').replace('\t', '').split(",")
        with open(tags_files[metric], "r") as myfile:
            tags_dict[metric] = myfile.read().replace('\n', '').replace('\t', '').split(",")

    return metrics_dict, tags_dict, template


def process_line(line, metrics_dict, tags_dict, template):
    if not line:
        return
    results = list()
    fields = line.strip().split(",")
    line_type = fields[0]

    data_point = template
    # TIMESTAMP
    data_point = data_point.replace("{timestamp}", fields[2])

    for metric in metrics_dict[line_type]:
        data_metric = data_point
        metric, position = metric.split(":")
        # METRIC
        data_metric = data_metric.replace("{metric}", metric)
        # VALUE
        data_metric = data_metric.replace("{value}", fields[int(position)])

        # TAGS
        # Surprisingly faster than printing and using a dict and much faster than using json...
        # So don't change it
        tags = "{"
        for tag in tags_dict[line_type]:
            tag, position = tag.split(":")
            tags += '"' + tag + '":"' + fields[int(position)] + '",'
        tags = tags[:-1]
        tags += '}'
        data_metric = data_metric.replace("{tags}", tags)

        results.append(data_metric)
        # sys.stdout.write(data_metric + "\n")
    return results


def behave_like_pipeline():
    metrics_dict, tags_dict, template = initialize()
    current_line = None
    try:
        for line in fileinput.input():
        #while True:
        #    line = sys.stdin.readline()
            results = process_line(line, metrics_dict, tags_dict, template)
            if results:
                for result in results:
                    sys.stdout.write(result + "\n")
            current_line = line
    except (KeyboardInterrupt, IOError):
        # Exit silently
        pass
    except Exception as error:
        eprint("[CSV TO JSON] error : " + str(error))
        eprint("[CSV TO JSON] line is : " + current_line)


def main():
    behave_like_pipeline()


if __name__ == "__main__":
    main()
