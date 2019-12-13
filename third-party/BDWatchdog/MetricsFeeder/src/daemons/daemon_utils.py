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
import abc
import traceback
from threading import Thread
import os
import time
import configparser
import errno
import subprocess
import sys
import logging

import requests

_base_path = os.path.dirname(os.path.abspath(__file__))


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


class MonitoringDaemon:
    __metaclass__ = abc.ABCMeta

    def __init__(self, service_name, environment):
        self.SERVICE_NAME = service_name
        self.environment = environment
        self.stdin_path = '/dev/null'
        self.stderr_path = os.path.join(self.environment["BDW_LOG_DIR"], self.SERVICE_NAME + ".err")
        self.stdout_path = os.path.join(self.environment["BDW_LOG_DIR"], self.SERVICE_NAME + ".out")
        self.log_path = os.path.join(self.environment["BDW_LOG_DIR"], self.SERVICE_NAME + ".log")
        self.configure_daemon_log()
        self.pidfile_path = os.path.join(self.environment["BDW_PID_DIR"], self.SERVICE_NAME + ".pid")
        self.pidfile_timeout = 5
        self.pipeline_tries = 0
        self.MAX_TRIES = 5
        self.processes_list = []
        self.dumper_thread = None
        self.is_runnable = None
        self.not_runnable_message = None

    def set_logger(self, logger):
        self.logger = logger

    def reload_pipeline(self, _signo, _stack_frame):
        self.logger.info("Going to reload pipeline")
        self.destroy_pipeline()
        self.processes_list = list()
        self.launch_pipeline()

    def launch_pipeline(self):
        self.logger.info("Launching pipeline")
        self.processes_list += self.create_pipeline()
        # Launch thread to log last process output (send to opentsdb of pipeline)
        thread = Thread(target=self.threaded_read_last_process_output, args=(self.processes_list[-1],))
        thread.start()
        self.dumper_thread = thread

    def beat(self):
        # Serverless Containers
        from src.StateDatabase import couchdb as couchDB
        from src.MyUtils import MyUtils as MyUtils
        self.logger.info("Starting heartbeat of " + self.SERVICE_NAME)
        db_handler = couchDB.CouchDBServer()
        while True:
            try:
                MyUtils.beat(db_handler, self.SERVICE_NAME)
                time.sleep(10)
            except ValueError:
                # Service not found:
                # - maybe it doesn't exist at all, register it
                # - it may have been deleted while the daemon was running, re-register it
                register_service(db_handler, self.SERVICE_NAME)
            except requests.ConnectionError:
                # Error connecting to the Couchdb database, ignore as it may be temporary
                pass

    def launch_heartbeat(self):
        # Launch the heartbeat thread
        if "HEARTBEAT_ENABLED" in self.environment and self.environment["HEARTBEAT_ENABLED"] == "true":
            # Launch heartbeat thread
            heartbeat = Thread(target=self.beat, args=())
            heartbeat.daemon = True
            heartbeat.start()

    @staticmethod
    def threaded_read_last_process_output(process):
        for line in process.stdout:
            print(line.strip())  # Dump to stdout of daemon
            sys.stdout.flush()

    @staticmethod
    def good_finish():
        sys.exit(0)

    @staticmethod
    def bad_finish():
        sys.exit(1)

    @staticmethod
    def create_pipe(cmd, environment, pipe_input, pipe_output):
        return subprocess.Popen(cmd,
                                env=environment,
                                stdin=pipe_input,
                                stdout=pipe_output
                                )

    # Terminate all the programs that create the pipeline
    def destroy_pipeline(self):
        self.logger.info("Destroying pipeline")
        for process in self.processes_list:
            try:
                process.terminate()
                process.wait()
                self.logger.info(
                    "Process " + str(process.pid) + " terminated with exit status " + str(process.returncode))
            except OSError:
                # Process may have already exited
                pass

    def poll_for_exited_processes(self):
        for process in self.processes_list:
            process.poll()
            if process.returncode is not None:
                return True
        return False

    def check_if_runnable(self):
        if not self.is_runnable(self.environment):
            eprint(self.not_runnable_message)

    def loop(self):
        try:
            while True:
                exited_processes = self.poll_for_exited_processes()
                if exited_processes:
                    self.logger.info("Error in pipeline")
                    self.destroy_pipeline()
                    if self.pipeline_tries < self.MAX_TRIES:
                        self.pipeline_tries += 1
                        self.logger.info("The pipeline was destroyed, re-creating and launching a new one")

                        self.launch_pipeline()

                    else:
                        self.logger.info(
                            "Pipeline failed too many times, (" + str(self.MAX_TRIES) + "), stopping daemon")
                        self.bad_finish()
                time.sleep(5)
        except(SystemExit, KeyboardInterrupt):
            self.logger.info("Exception or signal caught, stopping daemon and destroying the pipeline.")
            self.destroy_pipeline()
            self.good_finish()

    def configure_daemon_log(self):
        logger = logging.getLogger(self.SERVICE_NAME)
        logger.setLevel(logging.INFO)
        formatter = logging.Formatter("%(asctime)s - %(name)s - %(message)s")

        log_path = self.environment["BDW_LOG_DIR"]
        check_path_existance_and_create(log_path)
        pids_path = self.environment["BDW_PID_DIR"]
        check_path_existance_and_create(pids_path)

        handler = logging.FileHandler(self.log_path)
        handler.setFormatter(formatter)
        logger.addHandler(handler)

        self.logger = logger
        self.handler = handler

    def get_handler(self):
        return self.handler

    @abc.abstractmethod
    def create_pipeline(self):
        """Method documentation"""
        return []


def command_is_runnable(command_as_list):
    try:
        subprocess.check_call(command_as_list, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception as e:
        eprint(str(e) + " " + str(traceback.format_exc()))
        return False
    return True


def initialize_environment(config_path, config_keys, default_environment_values):
    environment = create_environment(read_config(config_path, config_keys),
                                     config_keys,
                                     default_environment_values)
    return environment


def create_environment(config_dict, config_keys, default_environment_values):
    custom_environment = os.environ.copy()

    for key in config_keys:
        if key in custom_environment:
            # Key has already been configured at the environment level
            pass
        elif key in config_dict.keys():
            # Key has been read from config file
            custom_environment[key] = config_dict[key]
        else:
            # Key was neither present at the environment level nor in the config file
            # Take default value
            custom_environment[key] = default_environment_values[key]

    return custom_environment


def read_config(config_path, config_keys):
    config_dict = {}
    config = configparser.ConfigParser()
    config.read(os.path.join(_base_path, config_path))
    for key in config_keys:
        try:
            config_dict[key] = config['DEFAULT'][key]
        except KeyError:
            pass  # Key is not configured, take the default value
    return config_dict


def check_path_existance_and_create(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise


def register_service(db_handler, service_name):
    service = dict(
        name=service_name,
        heartbeat="",
        heartbeat_human="",
        type="service"
    )
    MyUtils.register_service(db_handler, service)
