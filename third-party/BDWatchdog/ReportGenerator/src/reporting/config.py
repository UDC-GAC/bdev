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

import configparser
import os
import sys

from ReportGenerator.src.reporting.utils import get_int_value, get_float_value
from ReportGenerator.src.opentsdb import bdwatchdog


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


class MongoDBConfig:
    __base_path = os.path.dirname(os.path.abspath(__file__))
    __config_path = "../../conf/timestamping_config.ini"
    __config_keys = [
        "TESTS_POST_ENDPOINT",
        "EXPERIMENTS_POST_ENDPOINT",
        "MAX_CONNECTION_TRIES",
        "MONGODB_IP",
        "MONGODB_PORT",
        "MONGODB_USER"
    ]
    __default_config_values = {
        "TESTS_POST_ENDPOINT": "tests",
        "EXPERIMENTS_POST_ENDPOINT": "experiments",
        "MAX_CONNECTION_TRIES": 3,
        "MONGODB_IP": "times",
        "MONGODB_PORT": 8000,
        "MONGODB_USER": "root"
    }

    def read_config(self):
        config_dict = {}
        config = configparser.ConfigParser()
        config_file_path = os.path.join(self.__base_path, self.__config_path)

        try:
            config.read(config_file_path)
        except (IOError, FileNotFoundError):
            print('Config file does not exist or is not accessible')

        for key in self.__config_keys:
            try:
                config_dict[key] = config['DEFAULT'][key]
            except KeyError:
                config_dict[key] = self.__default_config_values[key]
        return config_dict

    def get_username(self):
        return self.config["MONGODB_USER"]

    def __init__(self):
        self.config = self.read_config()

    def get_config_as_dict(self):
        return self.config


class ReporterConfig:
    __base_path = os.path.dirname(os.path.abspath(__file__))
    __config_path = "../../conf/report_generator_config.ini"
    __config_keys = [
        "MAX_DIFF_TIME",
        "PRINT_MISSING_INFO_REPORT",
        "PRINT_NODE_INFO",
        "GENERATE_APP_PLOTS",
        "GENERATE_NODES_PLOTS",
        "GENERATE_EXPERIMENT_PLOT",
        "GENERATE_USER_PLOTS",
        "PLOTTING_FORMATS",
        "NODES_LIST",
        "APPS_LIST",
        "USERS_LIST",
        "NUM_BASE_EXPERIMENTS",
        "TEST_TYPE_STEPPING",
        "PRINT_TEST_BASIC_INFORMATION",
        "STATIC_LIMITS",
        "Y_AMPLIFICATION_FACTOR",
        "XLIM",
        "YLIM",
        "XTICKS_STEP",
        "REPORTED_RESOURCES",
        "EXPERIMENT_TYPE",
        "PRINT_ENERGY_MAX",
        "DOWNSAMPLE"
    ]
    __default_environment_values = {
        "NUM_BASE_EXPERIMENTS": 3,
        "MAX_DIFF_TIME": 10,
        "PRINT_MISSING_INFO_REPORT": "true",
        "PRINT_NODE_INFO": "true",
        "GENERATE_APP_PLOTS": "true",
        "GENERATE_NODES_PLOTS": "true",
        "GENERATE_EXPERIMENT_PLOT": "false",
        "GENERATE_USER_PLOTS": "false",
        "PLOTTING_FORMATS": "svg",
        "TEST_TYPE_STEPPING": 3,
        "PRINT_TEST_BASIC_INFORMATION": "false",
        "STATIC_LIMITS": "true",
        "NODES_LIST": "node1,node2,node3,node4,node5,node6,node7,node8,node9",
        "USERS_LIST": "user0",
        "APPS_LIST": "app1",
        "Y_AMPLIFICATION_FACTOR": 1.2,
        "XLIM": 2000,
        "YLIM": "cpu:default:10000,energy:default:2000",
        "XTICKS_STEP": 100,
        "REPORTED_RESOURCES": "cpu,mem",
        "EXPERIMENT_TYPE": "serverless",
        "PRINT_ENERGY_MAX": "true",
        "DOWNSAMPLE": 5
    }

    __ALLOWED_EXPERIMENT_TYPES = ["serverless", "untreated", "energy"]
    __DEFAULT_EXPERIMENT_TYPE = "serverless"

    def read_config(self):
        config_dict = {}
        config = configparser.ConfigParser()
        config_file_path = os.path.join(self.__base_path, self.__config_path)

        try:
            config.read(config_file_path)
        except (IOError, FileNotFoundError):
            print('Config file does not exist or is not accessible')

        for key in self.__config_keys:
            try:
                config_dict[key] = config['DEFAULT'][key]
            except KeyError:
                pass  # Key is not configured, leave it
        return config_dict

    def create_environment(self):
        custom_environment = os.environ.copy()
        config_dict = self.read_config()
        for key in self.__config_keys:
            if key in config_dict.keys():
                custom_environment[key] = config_dict[key]
            else:
                custom_environment[key] = self.__default_environment_values[key]
        return custom_environment

    def __init__(self):
        ENV = self.create_environment()

        self.REPORTED_RESOURCES = ENV["REPORTED_RESOURCES"].rstrip('"').lstrip('"').split(",")
        self.MAX_DIFF_TIME = get_int_value(ENV, "MAX_DIFF_TIME", self.__default_environment_values["MAX_DIFF_TIME"])

        self.EXPERIMENT_TYPE = ENV["EXPERIMENT_TYPE"]
        if self.EXPERIMENT_TYPE not in self.__ALLOWED_EXPERIMENT_TYPES:
            self.EXPERIMENT_TYPE = self.__DEFAULT_EXPERIMENT_TYPE

        self.BDWATCHDOG_USER_METRICS = list()
        if "cpu" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_USER_METRICS.append(('user.cpu.current', 'user'))
            self.BDWATCHDOG_USER_METRICS.append(('user.cpu.usage', 'user'))
        if "energy" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_USER_METRICS.append(('user.energy.max', 'user'))
            self.BDWATCHDOG_USER_METRICS.append(('user.energy.used', 'user'))

        self.BDWATCHDOG_APP_METRICS = list()
        if "cpu" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_APP_METRICS.append(('structure.cpu.current', 'structure'))
            self.BDWATCHDOG_APP_METRICS.append(('structure.cpu.usage', 'structure'))
        if "mem" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_APP_METRICS.append(('structure.mem.current', 'structure'))
            self.BDWATCHDOG_APP_METRICS.append(('structure.mem.usage', 'structure'))
        if "disk" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_APP_METRICS.append(('structure.disk.current', 'structure'))
            self.BDWATCHDOG_APP_METRICS.append(('structure.disk.usage', 'structure'))
        if "net" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_APP_METRICS.append(('structure.net.current', 'structure'))
            self.BDWATCHDOG_APP_METRICS.append(('structure.net.usage', 'structure'))
        if "energy" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_APP_METRICS.append(('structure.energy.max', 'structure'))
            self.BDWATCHDOG_APP_METRICS.append(('structure.energy.usage', 'structure'))

        self.BDWATCHDOG_NODE_METRICS = list()
        if "cpu" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_NODE_METRICS += [('structure.cpu.current', 'structure'), ('proc.cpu.user', 'host'),
                                             ('proc.cpu.kernel', 'host'), ('limit.cpu.upper', 'structure'),
                                             ('limit.cpu.lower', 'structure')]
        if "mem" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_NODE_METRICS += [('structure.mem.current', 'structure'), ('proc.mem.resident', 'host'),
                                             ('proc.mem.virtual', 'host'), ('limit.mem.upper', 'structure'),
                                             ('limit.mem.lower', 'structure')]
        if "disk" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_NODE_METRICS += [('structure.disk.current', 'structure'), ('proc.disk.reads.mb', 'host'),
                                             ('proc.disk.writes.mb', 'host'), ('limit.disk.upper', 'structure'),
                                             ('limit.disk.lower', 'structure')]
        if "net" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_NODE_METRICS += [('structure.net.current', 'structure'), ('proc.net.tcp.out.mb', 'host'),
                                             ('limit.net.upper', 'structure'), ('limit.net.lower', 'structure'),
                                             ('proc.net.tcp.in.mb', 'host'), ('structure.energy.usage', 'structure')]
        if "energy" in self.REPORTED_RESOURCES:
            self.BDWATCHDOG_NODE_METRICS += [('sys.cpu.energy', 'host')]

        self.PRINT_ENERGY_MAX = ENV["PRINT_ENERGY_MAX"] == "true"
        self.PRINTED_METRICS = list()
        if "cpu" in self.REPORTED_RESOURCES:
            self.PRINTED_METRICS += ['structure.cpu.current', 'structure.cpu.usage']
            self.PRINTED_METRICS += ['proc.cpu.user', 'proc.cpu.kernel']

        if "mem" in self.REPORTED_RESOURCES:
            self.PRINTED_METRICS += ['structure.mem.current', 'structure.mem.usage']
            self.PRINTED_METRICS += ['proc.mem.resident', 'proc.mem.virtual']

        if "disk" in self.REPORTED_RESOURCES:
            self.PRINTED_METRICS += ['structure.disk.current', 'structure.disk.usage']
            self.PRINTED_METRICS += ['proc.disk.reads.mb', 'proc.disk.writes.mb']

        if "net" in self.REPORTED_RESOURCES:
            self.PRINTED_METRICS += ['structure.net.current', 'structure.net.usage']
            self.PRINTED_METRICS += ['proc.net.tcp.out.mb', 'proc.net.tcp.in.mb']

        if "energy" in self.REPORTED_RESOURCES:
            self.PRINTED_METRICS += ['structure.energy.usage']
            self.PRINTED_METRICS += ['structure.energy.max']

        self.MAX_COLUMNS = {"print_test_resources": 5,
                            "print_summarized_tests_info": 8,
                            "print_tests_resource_utilization_report": 8,
                            "print_tests_resource_overhead_report": 8,
                            "print_tests_by_resource_report": 5,
                            "print_tests_resource_hysteresis_report": 8,
                            "print_tests_resource_overhead_report_with_stepping": 6,
                            "print_tests_resource_utilization_with_stepping": 6}

        self.STATIC_LIMITS = ENV["STATIC_LIMITS"] == "true"

        self.Y_AMPLIFICATION_FACTOR = get_float_value(ENV, "Y_AMPLIFICATION_FACTOR",
                                                      self.__default_environment_values["Y_AMPLIFICATION_FACTOR"])

        #self.XLIM = get_int_value(ENV, "XLIM", self.__default_environment_values["XLIM"])

        self.XLIM = {"default": 1000}
        for pair in ENV["XLIM"].rstrip('"').lstrip('"').split(","):
            structure_name, limit = pair.split(":")
            try:
                self.XLIM[structure_name] = int(limit)
            except ValueError:
                pass

        self.YLIM = dict()
        for pair in ENV["YLIM"].rstrip('"').lstrip('"').split(","):
            resource, structure_name, limit = pair.split(":")
            if resource in ["cpu", "energy"]:
                try:
                    if structure_name not in self.YLIM:
                        self.YLIM[structure_name] = dict()
                    self.YLIM[structure_name][resource] = int(limit)
                except ValueError:
                    pass

        self.XTICKS_STEP = get_int_value(ENV, "XTICKS_STEP", self.__default_environment_values["XTICKS_STEP"])

        self.PRINT_MISSING_INFO_REPORT = ENV["PRINT_MISSING_INFO_REPORT"] == "true"
        self.PRINT_NODE_INFO = ENV["PRINT_NODE_INFO"] == "true"
        self.GENERATE_APP_PLOTS = ENV["GENERATE_APP_PLOTS"] == "true"
        self.GENERATE_NODES_PLOTS = ENV["GENERATE_NODES_PLOTS"] == "true"
        self.GENERATE_EXPERIMENT_PLOT = ENV["GENERATE_EXPERIMENT_PLOT"] == "true"
        self.GENERATE_USER_PLOTS= ENV["GENERATE_USER_PLOTS"] == "true"

        self.PLOTTING_FORMATS = list()
        plotting_formats = ENV["PLOTTING_FORMATS"].rstrip('"').lstrip('"').split(",")
        if "png" in plotting_formats:
            self.PLOTTING_FORMATS.append("png")
        if "svg" in plotting_formats:
            self.PLOTTING_FORMATS.append("svg")

        self.NUM_BASE_EXPERIMENTS = get_int_value(ENV, "NUM_BASE_EXPERIMENTS",
                                                  self.__default_environment_values["NUM_BASE_EXPERIMENTS"])

        self.TEST_TYPE_STEPPING = get_int_value(ENV, "TEST_TYPE_STEPPING",
                                                self.__default_environment_values["TEST_TYPE_STEPPING"])
        self.bdwatchdog_handler = bdwatchdog.BDWatchdog()
        self.DOWNSAMPLE = get_int_value(ENV, "DOWNSAMPLE", self.__default_environment_values["DOWNSAMPLE"])


        self.RESOURCE_UTILIZATION_TUPLES = list()
        if "cpu" in self.REPORTED_RESOURCES:
            self.RESOURCE_UTILIZATION_TUPLES.append(("cpu", "structure.cpu.current", "structure.cpu.usage"))

        if "mem" in self.REPORTED_RESOURCES:
            self.RESOURCE_UTILIZATION_TUPLES.append(("mem", "structure.mem.current", "structure.mem.usage"))

        if "energy" in self.REPORTED_RESOURCES:
            self.RESOURCE_UTILIZATION_TUPLES.append(("energy", "structure.energy.max", "structure.energy.usage"))

        self.USAGE_METRICS_SOURCE = list()
        if "cpu" in self.REPORTED_RESOURCES:
            self.USAGE_METRICS_SOURCE.append(("structure.cpu.usage", ['proc.cpu.user', 'proc.cpu.kernel']))
        if "mem" in self.REPORTED_RESOURCES:
            self.USAGE_METRICS_SOURCE.append(("structure.mem.usage", ['proc.mem.resident']))
        if "disk" in self.REPORTED_RESOURCES:
            self.USAGE_METRICS_SOURCE.append(("structure.disk.usage", ['proc.disk.writes.mb', 'proc.disk.reads.mb']))
        if "net" in self.REPORTED_RESOURCES:
            self.USAGE_METRICS_SOURCE.append(("structure.net.usage", ['proc.net.tcp.in.mb', 'proc.net.tcp.out.mb']))
        if "energy" in self.REPORTED_RESOURCES:
            self.USAGE_METRICS_SOURCE.append(("structure.energy.usage", ['sys.cpu.energy']))

        self.METRICS_TO_CHECK_FOR_MISSING_DATA = list()
        if "cpu" in self.REPORTED_RESOURCES:
            self.METRICS_TO_CHECK_FOR_MISSING_DATA += [('structure.cpu.current', 'structure'),
                                                       ('proc.cpu.user', 'host'),
                                                       ('proc.cpu.kernel', 'host')]
        if "mem" in self.REPORTED_RESOURCES:
            self.METRICS_TO_CHECK_FOR_MISSING_DATA += [('structure.mem.current', 'structure'),
                                                       ('proc.mem.resident', 'host')]

        if "energy" in self.REPORTED_RESOURCES:
            self.METRICS_TO_CHECK_FOR_MISSING_DATA += [('structure.energy.usage', 'structure')]

        self.METRICS_FOR_OVERHEAD_REPORT = list()
        if "cpu" in self.REPORTED_RESOURCES:
            self.METRICS_FOR_OVERHEAD_REPORT += [("cpu used", "structure.cpu.usage"),
                                                 ("cpu allocated", "structure.cpu.current")]
        if "mem" in self.REPORTED_RESOURCES:
            self.METRICS_FOR_OVERHEAD_REPORT += [("mem used", "structure.mem.usage"),
                                                 ("mem allocated", "structure.mem.current")]
        if "energy" in self.REPORTED_RESOURCES:
            self.METRICS_FOR_OVERHEAD_REPORT += [("energy allowed", "structure.energy.max"),
                                                 ("energy used", "structure.energy.usage")]

        self.PRINT_TEST_BASIC_INFORMATION = ENV["PRINT_TEST_BASIC_INFORMATION"] == "true"
        self.NODES_LIST = ENV["NODES_LIST"].rstrip('"').lstrip('"').split(",")

        self.APPS_LIST = ENV["APPS_LIST"].rstrip('"').lstrip('"').split(",")

        self.USERS_LIST = ENV["USERS_LIST"].rstrip('"').lstrip('"').split(",")
