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
import subprocess
import signal
from daemon import runner
import socket

import MetricsFeeder.src.daemons.daemon_utils as daemon_utils
from MetricsFeeder.src.daemons.daemon_utils import MonitoringDaemon

SERVICE_NAME = "Nethogs_" + str(socket.gethostname())

_base_path = os.path.dirname(os.path.abspath(__file__))

config_path = "conf/nethogs_config.ini"

config_keys = [
    "NETHOGS_SAMPLING_FREQUENCY",
    "POST_ENDPOINT_PATH",
    "POST_DOC_BUFFER_TIMEOUT",
    "PYTHONUNBUFFERED",
    "TEMPLATE_PATH",
    "METRICS_PATH",
    "TAGS_PATH",
    "POST_DOC_BUFFER_LENGTH",
    "POST_SEND_DOCS_TIMEOUT",
    "POST_SEND_DOCS_FAILED_TRIES",
    "JAVA_TRANSLATION_ENABLED",
    "JAVA_MAPPINGS_FOLDER_PATH",
    "JAVA_TRANSLATOR_MAX_TRIES",
    "JAVA_TRANSLATOR_WAIT_TIME",
    "HADOOP_SNITCH_FOLDER_PATH",
    "HEARTBEAT_ENABLED",
    "BDW_LOG_DIR",
    "BDW_PID_DIR",
    "USE_PACKED_BINARIES",
    "NETHOGS_BINARIES_PATH",
]

default_environment_values = {
    "NETHOGS_SAMPLING_FREQUENCY": "5",
    "POST_ENDPOINT_PATH": "http://opentsdb:4242/api/put",
    "POST_DOC_BUFFER_TIMEOUT": "5",
    "PYTHONUNBUFFERED": "yes",
    "TEMPLATE_PATH": os.path.join(_base_path, "../pipelines/templates/"),
    "METRICS_PATH": os.path.join(_base_path, "../pipelines/metrics/"),
    "TAGS_PATH": os.path.join(_base_path, "../pipelines/tags/"),
    "POST_DOC_BUFFER_LENGTH": "1000",  # Don't go over 1500 or post packet will be too large and may cause error
    "POST_SEND_DOCS_TIMEOUT": "5",
    "POST_SEND_DOCS_FAILED_TRIES": "6",
    "JAVA_TRANSLATION_ENABLED": "false",
    "JAVA_MAPPINGS_FOLDER_PATH": os.path.join(_base_path, "../java_mappings/"),
    "JAVA_TRANSLATOR_MAX_TRIES": "4",
    "JAVA_TRANSLATOR_WAIT_TIME": "3",
    "HADOOP_SNITCH_FOLDER_PATH": os.path.join(_base_path, "../java_hadoop_snitch/"),
    "HEARTBEAT_ENABLED": "false",
    "BDW_LOG_DIR": os.path.join(_base_path, "logs/"),
    "BDW_PID_DIR": os.path.join(_base_path, "pids/"),
    "USE_PACKED_BINARIES": "true",
    "NETHOGS_BINARIES_PATH": os.path.join(_base_path, "../../bin/nethogs/"),
}


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def nethogs_is_runnable(environment):
    # Run a bogus 'ls' command to show nethogs statistics for a few seconds
    # If the command doesn't fail, nethogs works
    # return daemon_utils.command_is_runnable(['../../nethogs/src/nethogs', '-v', '3', '-t', '-d', '1', '-c', '2'])
    return daemon_utils.command_is_runnable(
        [environment["NETHOGS_BINARIES_PATH"] + '/nethogs', '-v', '3', '-t', '-d', '1', '-c', '2'])


class Nethogs(MonitoringDaemon):

    def run(self):
        self.launch_pipeline()
        self.launch_heartbeat()
        self.loop()

    def create_pipeline(self):
        processes_list = []

        # Create the data source
        nethogs = subprocess.Popen(
            ["bash", os.path.join(_base_path, "../nethogs/run_nethogs.sh"),
             self.environment["NETHOGS_SAMPLING_FREQUENCY"]],
            env=self.environment, stdout=subprocess.PIPE)
        processes_list.append(nethogs)

        # Create the data pipeline
        filtered_nethogs_output = self.create_pipe(
            ["python3", os.path.join(_base_path, "../nethogs/filter_raw_output.py")], self.environment,
            nethogs.stdout,
            subprocess.PIPE)
        processes_list.append(filtered_nethogs_output)

        if self.environment["JAVA_TRANSLATION_ENABLED"] == "true":
            # With JAVA mapping
            nethogs_to_json = self.create_pipe(
                ["python3", os.path.join(_base_path, "../nethogs/nethogs_to_json_with_java_translation.py")],
                self.environment,
                filtered_nethogs_output.stdout,
                subprocess.PIPE)
        else:
            # Without JAVA mapping
            nethogs_to_json = self.create_pipe(
                ["python3", os.path.join(_base_path, "../nethogs/nethogs_to_json.py")], self.environment,
                filtered_nethogs_output.stdout,
                subprocess.PIPE)

        send_to_opentsdb = self.create_pipe(["python3", os.path.join(_base_path, "../pipelines/send_to_OpenTSDB.py")],
                                            self.environment, nethogs_to_json.stdout, subprocess.PIPE)
        processes_list.append(send_to_opentsdb)

        return processes_list


if __name__ == '__main__':
    environment = daemon_utils.initialize_environment(config_path, config_keys, default_environment_values)
    app = Nethogs(SERVICE_NAME, environment)
    handler = app.get_handler()
    app.is_runnable = nethogs_is_runnable
    app.not_runnable_message = "Nethogs program is not runnable, check that it has been " \
                               "installed in directory: " + environment["NETHOGS_BINARIES_PATH"] + \
                               " and that persmission is granted " +\
                               "(run scripts/allow_priviledges/allow_nethogs.sh if needed)"
    app.check_if_runnable()

    # Capture reload signal and propagate
    signal.signal(signal.SIGHUP, app.reload_pipeline)

    # Run service
    serv = runner.DaemonRunner(app)
    serv.daemon_context.files_preserve = [handler.stream]
    serv.do_action()
