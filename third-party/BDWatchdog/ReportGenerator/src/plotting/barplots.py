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
import pandas as pd
import matplotlib.pyplot as plt

from ReportGenerator.src.plotting.utils import translate_test_run_name_by_conf_number, \
    BARPLOTS_FIGURE_SIZE, OVERHEAD_VALUE_SIZE, save_figure, get_y_limit
from ReportGenerator.src.reporting.config import ReporterConfig
from ReportGenerator.src.reporting.utils import translate_metric, some_test_has_missing_aggregate_information

# Get the config
cfg = ReporterConfig()


def translate_shares_to_vcore_minutes(bars):
    return [x / (100 * 60) for x in bars]


def translate_MBseconds_to_GBminutes(bars):
    return [x / (1024 * 60) for x in bars]


ylabels = {"cpu": "CPU (Vcore-minutes)", "mem": "Memory (GB-minutes)"}
convert_functions = {"cpu": translate_shares_to_vcore_minutes, "mem": translate_MBseconds_to_GBminutes}


def save_barplot_figure(figure_name, fig, benchmark_type):
    figure_filepath_directory = "resource_barplots/{0}".format(benchmark_type)
    save_figure(figure_filepath_directory, figure_name, fig)


def plot_tests_resource_usage(tests):
    width, height = int(len(tests) / 3), 8
    figure_size = (width, height)
    benchmark_type = tests[0]["test_name"].split("_")[0]
    resource_list = ["structure.cpu.current",
                     "structure.cpu.usage",
                     "structure.mem.current",
                     "structure.mem.usage",
                     "structure.energy.max",
                     "structure.energy.usage"]

    for resource in resource_list:
        labels = []
        values_sum, values_avg = [], []
        splits = resource.split(".")
        resource_label, resource_metric = splits[1], splits[2]

        for test in tests:
            labels.append(test["test_name"].split("_")[1])
            if test["resource_aggregates"] == "n/a":
                values_sum.append(0)
                values_avg.append(0)
            else:
                resource_aggregate = test["resource_aggregates"]["ALL"][resource]
                if resource_label == "cpu":
                    values_sum.append(resource_aggregate["SUM"] / (100 * 60))
                    values_avg.append(resource_aggregate["AVG"] / 100)
                elif resource_label == "mem":
                    values_sum.append(resource_aggregate["SUM"] / (1024 * 60))
                    values_avg.append(resource_aggregate["AVG"] / 1024)
                elif resource_label == "energy":
                    values_sum.append(resource_aggregate["SUM"])
                    values_avg.append(resource_aggregate["AVG"])
                else:
                    values_sum.append(resource_aggregate["SUM"])
                    values_avg.append(resource_aggregate["AVG"])

        # Plot the data
        df = pd.DataFrame({'SUM': values_sum, 'AVG': values_avg}, index=labels)
        ax = df.plot.bar(
            rot=0,
            title=[translate_metric(resource), ""],
            subplots=True,
            figsize=figure_size,
            sharex=False)

        # Set the labels
        if resource_label == "cpu":
            ax[0].set_ylabel("Vcore-minutes")
            ax[1].set_ylabel("Vcore-seconds/second")
        elif resource_label == "mem":
            ax[0].set_ylabel("GB-minutes")
            ax[1].set_ylabel("GB-second/second")
        elif resource_label == "energy":
            ax[0].set_ylabel("Watts·h")
            ax[1].set_ylabel("Watts·h/s")
        else:
            ax[0].set_ylabel("Unknown")
            ax[1].set_ylabel("Unknown")
        ax[0].set_xlabel("# test-run")
        ax[1].set_xlabel("# test-run")

        # Set the Y limits
        top, bottom = get_y_limit("resource_usage", max(values_sum),
                                  benchmark_type=benchmark_type, resource_label=resource, static_limits=False)
        ax[0].set_ylim(top=top, bottom=bottom)

        # Save the plot
        figure_name = "{0}_{1}.{2}".format(resource_label, resource_metric, "svg")
        fig = ax[0].get_figure()
        save_barplot_figure(figure_name, fig, benchmark_type)
        plt.close()


def plot_tests_resource_usage_with_stepping(tests, num_base_experiments):
    resource_tuples = [("cpu used", "structure.cpu.usage"),
                       ("cpu allocated", "structure.cpu.current"),
                       ("mem used", "structure.mem.usage"),
                       ("mem allocated", "structure.mem.current")]

    labels = []
    bars, overheads, base_values = dict(), dict(), dict()
    benchmark_type = tests[0]["test_name"].split("_")[0]

    if some_test_has_missing_aggregate_information(tests):
        return

    # Compute the overheads for the baseline tests
    for resource_tuple in resource_tuples:
        resource, usage_metric = resource_tuple
        if resource not in bars:
            bars[resource] = []
            base_values[resource] = 0
            overheads[resource] = []
        for test in tests[:num_base_experiments]:
            base_values[resource] += test["resource_aggregates"]["ALL"][usage_metric]["SUM"]

        base_values[resource] = base_values[resource] / num_base_experiments
        bars[resource].append(base_values[resource])
        overheads[resource].append(0)

    configuration = 0
    labels.append(translate_test_run_name_by_conf_number(configuration, benchmark_type))
    configuration += 1

    # Compute the overheads for the remaining tests using the step (number of same configuration tests)
    index = num_base_experiments
    step = cfg.TEST_TYPE_STEPPING
    while index < len(tests):
        for resource_tuple in resource_tuples:
            resource, usage_metric = resource_tuple
            summary = 0
            for test in tests[index:index + step]:
                summary += test["resource_aggregates"]["ALL"][usage_metric]["SUM"]
            summary = summary / step
            overhead = summary / (base_values[resource])
            overheads[resource].append(str(int((overhead - 1) * 100)) + "%")
            bars[resource].append(summary)

        labels.append(translate_test_run_name_by_conf_number(configuration, benchmark_type))
        configuration += 1
        index += step

    for resource in ["cpu", "mem"]:

        # Transform the data
        bars["allocated"] = convert_functions[resource](bars["{0} allocated".format(resource)])
        bars["used"] = convert_functions[resource](bars["{0} used".format(resource)])

        # Plot the data
        df = pd.DataFrame({"Allocated": bars["allocated"], 'Used': bars["used"]}, index=labels)
        ax = df.plot.bar(
            rot=0,
            title="",
            figsize=BARPLOTS_FIGURE_SIZE,
            legend=True)

        # Set the labels
        ax.set_ylabel(ylabels[resource])
        if resource == "cpu":
            ax.set_xlabel("CPU usage")
        elif resource == "mem":
            ax.set_xlabel("Memory usage")
        else:
            ax.set_xlabel("")

        # Set the Y limits
        top, bottom = get_y_limit("resource_usage_with_stepping", max(bars["allocated"]),
                                  benchmark_type=benchmark_type, resource_label=resource,
                                  static_limits=cfg.STATIC_LIMITS)
        ax.set_ylim(top=top, bottom=bottom)

        # Set the numbers for the used and allocated values
        bars_positions = dict()
        bars_positions["allocated"] = [x for x in range(len(bars["allocated"]))]
        bars_positions["used"] = [x + 0.22 for x in range(len(bars["used"]))]
        for i in range(len(bars["used"]))[1:]:
            plt.text(x=bars_positions["used"][i],
                     y=bars["used"][i],
                     s=overheads["{0} used".format(resource)][i],
                     size=OVERHEAD_VALUE_SIZE)
            plt.text(x=bars_positions["allocated"][i],
                     y=bars["allocated"][i],
                     s=overheads["{0} allocated".format(resource)][i],
                     size=OVERHEAD_VALUE_SIZE)

        # Generate the utilization ratios
        bars["utilization"] = []
        for i in range(len(bars["allocated"])):
            bars["utilization"].append(int(100 * bars["used"][i] / bars["allocated"][i]))

        # Plot utilization ratios
        df = pd.DataFrame({'Utilization': bars["utilization"]}, index=labels)
        ax = df['Utilization'].plot(
            secondary_y=True,
            color='k',
            marker='o',
            label="Utilization",
            legend=True
        )

        # Plot utilization numeric ratios for each point
        bars["utilization_string"] = [str(x) + "%" for x in bars["utilization"]]  # Convert to string labels
        ax.set_ylabel('Utilization (%)', style="italic", weight="bold")
        plt.ylim(top=100, bottom=0)

        if cfg.STATIC_LIMITS:
            if benchmark_type == "terasort":
                plt.xlim(left=-0.5, right=4.75)
            elif benchmark_type == "fixwindow":
                plt.xlim(left=-0.5, right=4.75)
            elif benchmark_type == "pagerank":
                plt.xlim(left=-0.5, right=1.5)

        else:
            plt.xlim(left=-0.5, right=len(bars["utilization_string"]))

        for i in range(len(bars["utilization"])):
            plt.text(x=bars_positions["used"][i],
                     y=bars["utilization"][i],
                     s=bars["utilization_string"][i],
                     style="italic",
                     weight="bold",
                     size=OVERHEAD_VALUE_SIZE)

        # Save the plot
        figure_name = "{0}_{1}.{2}".format(resource, "grouped", "svg")
        fig = ax.get_figure()
        save_barplot_figure(figure_name, fig, benchmark_type)
        plt.close()


def plot_tests_times_with_stepping(tests, num_base_experiments, basetime):
    overheads, durations, bars, labels = [], [], [], []
    configuration = 0
    benchmark_type = tests[0]["test_name"].split("_")[0]

    if some_test_has_missing_aggregate_information(tests):
        return

    labels.append(translate_test_run_name_by_conf_number(configuration, benchmark_type))
    configuration += 1

    bars.append(basetime)
    overheads.append(0)
    durations.append(basetime)

    index = num_base_experiments
    while index < len(tests):
        duration = 0
        for test in tests[index:index + cfg.TEST_TYPE_STEPPING]:
            duration += test["duration"]
        average_duration = duration / cfg.TEST_TYPE_STEPPING
        overhead = str(int((average_duration / basetime - 1) * 100)) + "%"

        durations.append(average_duration)
        overheads.append(overhead)
        bars.append(average_duration)
        labels.append(translate_test_run_name_by_conf_number(configuration, benchmark_type))

        configuration += 1
        index += cfg.TEST_TYPE_STEPPING

    # Translate from seconds to minutes
    bars = [x / 60 for x in bars]

    # Plot the data
    df = pd.DataFrame(bars, index=labels)
    ax = df.plot.bar(
        rot=0,
        title="",
        figsize=BARPLOTS_FIGURE_SIZE,
        legend=False)

    # Set the labels
    ax.set_ylabel("Time (minutes)")
    ax.set_xlabel("Overhead")
    # ax.set_xlabel(translate_benchmark(benchmark_type))

    # Set the Y limits
    top, bottom = get_y_limit("times_with_stepping", max(bars), benchmark_type=benchmark_type,
                              static_limits=cfg.STATIC_LIMITS)
    ax.set_ylim(top=top, bottom=bottom)

    # Label the overheads with a number
    bars_positions = [x for x in range(len(bars))]
    for i in range(len(bars))[1:]:
        plt.text(x=bars_positions[i],  # x=bars_positions[i] - 0.15,
                 y=bars[i],  # y=bars[i] + 0.5
                 s=overheads[i],
                 size=OVERHEAD_VALUE_SIZE)

    # Save the plot
    figure_name = "{0}_{1}.{2}".format("times", "grouped", "svg")
    fig = ax.get_figure()
    save_barplot_figure(figure_name, fig, benchmark_type)
    plt.close()


def plot_tests_times(tests):
    labels, durations_seconds, durations_minutes = [], [], []
    width, height = 8, int(len(tests) / 3)
    figure_size = (width, height)
    benchmark_type = tests[0]["test_name"].split("_")[0]

    for test in tests:
        seconds, minutes, overhead = 0, 0, 0
        labels.append(test["test_name"].split("_")[1])
        if test["duration"] != "n/a":
            seconds = test["duration"]
            minutes = "{:.2f}".format((test["duration"]) / 60)

        durations_seconds.append(seconds)
        durations_minutes.append(minutes)

    # Plot the data
    df = pd.DataFrame({'time': durations_seconds}, index=labels)
    ax = df.plot.barh(
        rot=0,
        title="Time and overheads",
        figsize=figure_size)

    # Set the labels
    ax.set_ylabel("test-run")
    ax.set_xlabel("Time (seconds)")

    # Save the plot
    figure_name = "{0}.{1}".format("times", "svg")
    fig = ax.get_figure()
    save_barplot_figure(figure_name, fig, benchmark_type)
    plt.close()
