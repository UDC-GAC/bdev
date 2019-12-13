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

import time
import json
import sys
import argparse

from TimestampsSnitch.src.mongodb.mongodb_agent import MongoDBTimestampAgent
from TimestampsSnitch.src.timestamping.utils import get_username, get_timestamp


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def signal_test(experiment_id, test_name, username, signal, timestamp):
    d = dict()
    info = dict()
    info["experiment_id"] = experiment_id
    info["username"] = username
    info["test_name"] = test_name
    info["test_id"] = experiment_id + "_" + test_name
    d["info"] = info
    d["type"] = "test"
    if not timestamp:
        timestamp = int(time.time())
    d["info"]["{0}_time".format(signal)] = timestamp
    print(json.dumps(d))


def print_test(test_data):
    doc_to_dump = {"type": "test", "info": {}}
    for field in ["username", "start_time", "end_time", "experiment_id", "test_id", "test_name"]:
        if field not in test_data:
            eprint("Field {0} missing from test {1}".format(field, test_data["test_id"]))
        else:
            doc_to_dump["info"][field] = test_data[field]
    print(json.dumps(doc_to_dump))


def get_test_info(experiment_name, test_name, username):
    if not mongodb_agent.experiment_exists(experiment_name, username):
        eprint("Couldn't find experiment with id {0}".format(experiment_name))
        exit(0)

    if not test_name or test_name == "ALL":
        tests = mongodb_agent.get_experiment_tests(experiment_name, username)
    else:
        test = mongodb_agent.get_test(experiment_name, test_name, username)
        if not test:
            tests = []
        else:
            tests = [test]

    if not tests:
        eprint("Couldn't find tests for experiment {0}".format(experiment_name))
        exit(0)

    for test in tests:
        print_test(test)


if __name__ == '__main__':
    mongodb_agent = MongoDBTimestampAgent()

    parser = argparse.ArgumentParser(description='Signal for the start, end times or for the deletion of a test.')
    parser.add_argument('option', metavar='option', type=str,
                        help='an operation option "info", "start", "end" or "delete"')
    parser.add_argument('experiment_name', metavar='experiment_name', type=str,
                        help='The name of the experiment that encompasses this test')
    parser.add_argument('test_name', metavar='test_name', type=str,
                        help='The name of the test')
    parser.add_argument('--time', type=str, default=None,
                        help="A time string in the form 'yyyy/mm/dd-HH:MM:SS' (e.g., '2018/06/01-12:34:36')")
    parser.add_argument('--username', type=str, default=None,
                        help="The username")

    args = parser.parse_args()

    username = get_username(args)

    if args.option == "start" or args.option == "end":
        signal_test(args.experiment_name, args.test_name, username, args.option, get_timestamp(args))
    elif args.option == "delete":
        mongodb_agent.delete_test(args.experiment_name, args.test_name, username)
    elif args.option == "info":
        get_test_info(args.experiment_name, args.test_name, username)
    else:
        eprint("Bad option")
        exit(1)
