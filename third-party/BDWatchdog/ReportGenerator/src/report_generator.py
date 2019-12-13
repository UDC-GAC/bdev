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
import time

from ReportGenerator.src.reporting.config import MongoDBConfig
from ReportGenerator.src.reporting.ExperimentReporter import ExperimentReporter
from TimestampsSnitch.src.mongodb.mongodb_agent import MongoDBTimestampAgent


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


mongoDBConfig = MongoDBConfig()
timestampingAgent = MongoDBTimestampAgent(mongoDBConfig.get_config_as_dict())
experimentReporter = ExperimentReporter()


def report_all_experiments():
    experiments = timestampingAgent.get_all_experiments(mongoDBConfig.get_username())
    if experiments:
        for exp in experiments:
            time_start = time.time()
            experimentReporter.report_experiment(exp)
            time_end = time.time()
            eprint("Reporting of experiment {0} took {1} seconds".format(exp["experiment_name"], time_end - time_start))


if __name__ == '__main__':
    eprint("[INFO] If you are running the 'generate_report.py', remember that the output is markdown for latex generation!!")
    eprint("[INFO] To get a nice report in PDF format, run the script 'generate_report.sh' with the same input as this python")
    if len(sys.argv) < 2:
        print("Must specify an experiment name")
    else:
        experiment_name = sys.argv[1]
        experiment = timestampingAgent.get_experiment(experiment_name, mongoDBConfig.get_username())
        if experiment:
            experimentReporter.report_experiment(experiment)
        else:
            eprint("No experiment '{0}' found".format(experiment_name))
