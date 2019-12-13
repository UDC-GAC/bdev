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

import argparse
import json
import sys

from TimestampsSnitch.src.mongodb.mongodb_agent import MongoDBTimestampAgent
from TimestampsSnitch.src.timestamping.utils import get_username, get_timestamp


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def signal_experiment(experiment_id, username, signal, timestamp):
    d = dict()
    info = dict()
    info["experiment_id"] = experiment_id
    info["username"] = username
    d["info"] = info
    d["type"] = "experiment"
    d["info"]["{0}_time".format(signal)] = timestamp
    print(json.dumps(d))


def print_experiment(experiment_data):
    doc_to_dump = {"type": "experiment", "info": {}}
    for field in ["username", "start_time", "end_time", "experiment_id"]:
        if field not in experiment_data:
            eprint("Field {0} missing from experiment {1}".format(field, experiment_data["experiment_id"]))
        else:
            doc_to_dump["info"][field] = experiment_data[field]
    print(json.dumps(doc_to_dump))


def get_experiment_info(experiment_name, username):
    if experiment_name == "ALL":
        data = mongodb_agent.get_all_experiments(username)
        if not data:
            eprint("Couldn't find experiment data, maybe there is none?")
            exit(0)
    else:
        data = mongodb_agent.get_experiment(experiment_name, username)
        if not data:
            eprint("Couldn't find experiment with id {0}".format(experiment_name))
            exit(0)

    if type(data) == type(dict()):
        print_experiment(data)
    elif type(data) == type(list()):
        for experiment in data:
            print_experiment(experiment)
    else:
        print_experiment(data)


if __name__ == '__main__':
    mongodb_agent = MongoDBTimestampAgent()

    parser = argparse.ArgumentParser(description='Signal for the start, end times or for the deletion of a test.')
    parser.add_argument('option', metavar='option', type=str,
                        help='an operation option "info", "start", "end" or "delete"')
    parser.add_argument('experiment_name', metavar='experiment_name', type=str,
                        help='The name of the experiment that encompasses this test')
    parser.add_argument('--time', type=str, default=None,
                        help="A time string in the form 'yyyy/mm/dd-HH:MM:SS' (e.g., '2018/06/01-12:34:36')")
    parser.add_argument('--username', type=str, default=None,
                        help="The username")
    args = parser.parse_args()

    username = get_username(args)

    if args.option == "start" or args.option == "end":
        signal_experiment(args.experiment_name, username, args.option, get_timestamp(args))
    elif args.option == "delete":
        mongodb_agent.delete_experiment(args.experiment_name, username)
    elif args.option == "info":
        get_experiment_info(args.experiment_name, username)
    else:
        eprint("Bad option")
        exit(1)
