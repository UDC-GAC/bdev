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

_base_path = os.path.dirname(os.path.abspath(__file__))
SERVICE_NAME = "Atop_" + str(socket.gethostname())

config_path = "conf/atop_config.ini"
config_keys = [
    "ATOP_SAMPLING_FREQUENCY",
    "METRICS",
    "POST_ENDPOINT_PATH",
    "POST_DOC_BUFFER_TIMEOUT",
    "PYTHONUNBUFFERED",
    "TEMPLATE_PATH",
    "METRICS_PATH",
    "TAGS_PATH",
    "POST_DOC_BUFFER_LENGTH",
    "POST_SEND_DOCS_TIMEOUT",
    "POST_SEND_DOCS_FAILED_TRIES",
    "JAVA_MAPPINGS_FOLDER_PATH",
    "JAVA_TRANSLATOR_MAX_TRIES",
    "JAVA_TRANSLATOR_WAIT_TIME",
    "JAVA_TRANSLATION_ENABLED",
    "HEARTBEAT_ENABLED",
    "BDW_LOG_DIR",
    "BDW_PID_DIR",
    "USE_PACKED_BINARIES",
    "BINARIES_PATH"
]
default_environment_values = {
    "ATOP_SAMPLING_FREQUENCY": "10",
    "METRICS": "CPU,cpu,MEM,SWP,DSK,NET,PRC,PRM,PRD,PRN",
    "POST_ENDPOINT_PATH": "http://opentsdb:4242/api/put",
    "POST_DOC_BUFFER_TIMEOUT": "30",
    "PYTHONUNBUFFERED": "yes",
    "TEMPLATE_PATH": os.path.join(_base_path, "../pipelines/templates/"),
    "METRICS_PATH": os.path.join(_base_path, "../pipelines/metrics/"),
    "TAGS_PATH": os.path.join(_base_path, "../pipelines/tags/"),
    "POST_DOC_BUFFER_LENGTH": "1000",  # Don't go over 1500 or post packet will be too large and may cause error
    "POST_SEND_DOCS_TIMEOUT": "30",
    "POST_SEND_DOCS_FAILED_TRIES": "6",
    "JAVA_MAPPINGS_FOLDER_PATH": os.path.join(_base_path, "../java_hadoop_snitch/java_mappings/"),
    "JAVA_TRANSLATOR_MAX_TRIES": "4",
    "JAVA_TRANSLATOR_WAIT_TIME": "3",
    "JAVA_TRANSLATION_ENABLED": "false",
    "HEARTBEAT_ENABLED": "false",
    "BDW_LOG_DIR": os.path.join(_base_path, "logs/"),
    "BDW_PID_DIR": os.path.join(_base_path, "pids/"),
    "USE_PACKED_BINARIES": "true",
    "BINARIES_PATH": os.path.join(_base_path, "../../bin/atop/"),
}


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def get_atop_executable(environment):
    if environment["USE_PACKED_BINARIES"] == "true":
        ATOP_EXECUTABLE = environment["BINARIES_PATH"] + "atop"
        eprint("Going to use pre-packed atop binary")
    else:
        ATOP_EXECUTABLE = "atop"
        eprint("Going to use system-level atop binary")
    return ATOP_EXECUTABLE


def atop_is_runnable(environment):
    # Run a bogus 'atop' command, show CPU usage every 1 seconds, 1 time
    # If the command doesn't fail, atop works
    ATOP_EXECUTABLE = get_atop_executable(environment)
    return daemon_utils.command_is_runnable([ATOP_EXECUTABLE, '1', '1', '-P', 'CPU'])


class Atop(MonitoringDaemon):

    def run(self):
        self.launch_pipeline()
        self.launch_heartbeat()
        self.loop()

    def create_pipeline(self):
        processes_list = []

        ATOP_EXECUTABLE = get_atop_executable(self.environment)

        # Launch Java snitch if java translation is going to be used
        if self.environment["JAVA_TRANSLATION_ENABLED"] == "true":
            # self.snitcher = self.launch_java_snitch()
            snitcher = self.launch_java_snitch()
            processes_list.append(snitcher)

        # Create the data source
        atop = subprocess.Popen(
            [ATOP_EXECUTABLE, self.environment["ATOP_SAMPLING_FREQUENCY"], '-P', self.environment["METRICS"]],
            stdout=subprocess.PIPE)

        processes_list.append(atop)

        # Create the data pipeline
        if self.environment["JAVA_TRANSLATION_ENABLED"] == "true":
            # With JAVA mapping
            atop_to_json = self.create_pipe(
                ["python3", os.path.join(_base_path, "../atop/atop_to_json_with_java_translation.py")],
                self.environment,
                atop.stdout,
                subprocess.PIPE)
        else:
            # Without JAVA mapping
            atop_to_json = self.create_pipe(
                ["python3", os.path.join(_base_path, "../atop/atop_to_json.py")], self.environment,
                atop.stdout,
                subprocess.PIPE)
        send_to_opentsdb = self.create_pipe(["python3", os.path.join(_base_path, "../pipelines/send_to_OpenTSDB.py")],
                                            self.environment,
                                            atop_to_json.stdout, subprocess.PIPE)
        processes_list.append(send_to_opentsdb)
        # Last process will have its output dumped

        return processes_list

    def launch_java_snitch(self):
        # Create the java snitch process
        java_snitch_process = subprocess.Popen(
            ["python3", os.path.join(_base_path, "../java_hadoop_snitch/java_snitch.py")],
            env=self.environment, stdout=subprocess.PIPE)
        return java_snitch_process


if __name__ == '__main__':
    environment = daemon_utils.initialize_environment(config_path, config_keys, default_environment_values)
    app = Atop(SERVICE_NAME, environment)
    handler = app.get_handler()
    app.is_runnable = atop_is_runnable
    app.not_runnable_message = "Atop program is not runnable or it is installed, " \
                               "if installed run atop manually and check for errors"
    app.check_if_runnable()

    # Capture reload signal and propagate
    signal.signal(signal.SIGHUP, app.reload_pipeline)

    # Run service
    serv = runner.DaemonRunner(app)
    serv.daemon_context.files_preserve = [handler.stream]
    serv.do_action()
