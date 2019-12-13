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

import numpy as np
import matplotlib.pyplot as plt

from ReportGenerator.src.plotting.utils import translate_plot_name_to_ylabel, line_style, dashes_dict, \
    line_marker, save_figure, TIMESERIES_FIGURE_SIZE
from ReportGenerator.src.reporting.config import ReporterConfig
from ReportGenerator.src.reporting.utils import translate_metric

# Get the config
cfg = ReporterConfig()


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def plot_document(doc, structure, plots, start_time, end_time, plotted_resources):
    if "test_name" in doc:
        doc_name = doc["test_name"]
        benchmark_type = doc["test_name"].split("_")[0]
    else:
        doc_name = doc["experiment_id"]
        benchmark_type = "EXPERIMENT"

    structure_name, structure_type = structure

    for resource in plots:
        if resource not in plotted_resources:
            continue

        # Pre-Check for empty plot (no timeseries for all the metrics)
        empty_plot = True
        for metric in plots[resource]:
            metric_name = metric[0]
            if metric_name not in doc["resources"][structure_name] or doc["resources"][structure_name][metric_name]:
                empty_plot = False
        if empty_plot:
            eprint("Plot '{0}' for doc {1} has no data, skipping".format(resource, doc_name))
            continue

        fig = plt.figure(figsize=TIMESERIES_FIGURE_SIZE)
        ax1 = fig.add_subplot(111)

        # TODO This should be moved to a function "trim"
        # Values used for trimming time series if necessary #
        check_range, ymin, ymax = False, 0, None
        if resource == "disk":
            check_range, ymin, ymax = True, 0, 200
            if structure_type == "node":
                check_range, ymin, ymax = True, 0, 200
            elif structure_type == "app":
                check_range, ymin, ymax = True, 0, 1200
        #####################################################

        # Values used for setting the X and Y limits, without depending on actual time series values ####
        if cfg.STATIC_LIMITS:
            if structure_name not in cfg.XLIM:
                max_x_ts_point_value = cfg.XLIM["default"]
            else:
                max_x_ts_point_value = cfg.XLIM[structure_name]
            if structure_name not in cfg.YLIM or resource not in cfg.YLIM[structure_name]:
                max_y_ts_point_value = cfg.YLIM["default"][resource]
            else:
                max_y_ts_point_value = cfg.YLIM[structure_name][resource]
        else:
            max_y_ts_point_value, max_x_ts_point_value = 0, 0
        ###########################################################

        for metric in plots[resource]:
            metric_name = metric[0]
            structure_resources = doc["resources"][structure_name]

            # Get the time series data
            if metric_name not in structure_resources or not structure_resources[metric_name]:
                continue

            timeseries = structure_resources[metric_name]

            # Apply range trimming if necessary
            if check_range:
                timeseries = cfg.bdwatchdog_handler.perform_timeseries_range_apply(timeseries, ymin, ymax)

            # Convert the time stamps to times relative to 0 (basetime)
            basetime = int(list(timeseries.keys())[0])
            x = list(map(lambda point: int(point) - basetime, timeseries))

            # # TODO HOTFIX
            # PADDING = 0
            # if structure_name == "comp_user0":
            #     if len(plots[resource]) == 1 and (
            #             metric_name == "structure.energy.usage" or metric_name == "structure.cpu.usage"):
            #         x = list(map(lambda point: 2800 + int(point) - basetime, timeseries))
            #         PADDING = 2800
            #     else:
            #         x = list(map(lambda point: 3100 + int(point) - basetime, timeseries))
            #         PADDING = 3100

            # Get the time series points and rebase them if necessary
            if resource == "mem":
                # Translate from MiB to GiB
                y = list(map(lambda point: int(int(point) / 1024), timeseries.values()))
            else:
                y = list(timeseries.values())

            # Set the maximum time series  time and value points
            # max_y_ts_point_value = max(max_y_ts_point_value, max(y))
            max_x_ts_point_value = max(max_x_ts_point_value, max(x))

            # Plot a time series
            linestyle = line_style[resource][metric_name]

            if len(plots[resource]) == 1 and metric_name == "structure.energy.usage":
                #### TODO Hotfix
                ax1.plot(x, y,
                         label=translate_metric(metric_name),
                         linestyle=linestyle,
                         dashes=dashes_dict[linestyle],
                         marker=line_marker[resource][metric_name],
                         markersize=6,
                         markevery=5,
                         color="tab:orange")
            else:
                ax1.plot(x, y,
                         label=translate_metric(metric_name),
                         linestyle=linestyle,
                         dashes=dashes_dict[linestyle],
                         marker=line_marker[resource][metric_name],
                         markersize=6,
                         markevery=5)

        # Set x and y limits
        top, bottom = max_y_ts_point_value, 0
        left, right = -30, max_x_ts_point_value + 30

        # If not static limits apply an amplification factor or the max timeseries value will be at the plot "ceiling"
        if not cfg.STATIC_LIMITS:
            top = int(float(top * cfg.Y_AMPLIFICATION_FACTOR))

        plt.xlim(left=left, right=right)
        plt.ylim(top=top, bottom=bottom)

        # Set properties to the whole plot
        plt.xlabel('Time(s)', fontsize=13)
        plt.ylabel(translate_plot_name_to_ylabel(resource), style="italic", weight="bold", fontsize=13)
        plt.title('')
        plt.grid(True)
        plt.legend(loc='upper right',
                   shadow=False,
                   fontsize='large',
                   fancybox=True,
                   facecolor='#afeeee',
                   labelspacing=0.15,
                   handletextpad=0.18,
                   borderpad=0.22)

        if cfg.STATIC_LIMITS:
            plt.xticks(np.arange(0, right, step=cfg.XTICKS_STEP))
        else:
            # May be inaccurate up to +- 'downsample' seconds,
            # because the data may start a little after the specified 'start' time or end
            # a little before the specified 'end' time
            plt.xticks(np.arange(0, int(end_time) - int(start_time), step=cfg.XTICKS_STEP))

        # Save the plot
        if "svg" in cfg.PLOTTING_FORMATS:
            figure_name = "{0}_{1}.{2}".format(structure_name, resource, "svg")
            figure_filepath_directory = "{0}/{1}/{2}".format("timeseries_plots", benchmark_type, doc_name)
            save_figure(figure_filepath_directory, figure_name, fig, format="svg")

        # Save the plot
        if "png" in cfg.PLOTTING_FORMATS:
            figure_name = "{0}_{1}.{2}".format(structure_name, resource, "png")
            figure_filepath_directory = "{0}/{1}/{2}".format("timeseries_plots", benchmark_type, doc_name)
            save_figure(figure_filepath_directory, figure_name, fig, format="png")
        plt.close()


def plot_user(doc, user, plots, start_time, end_time, plotted_resources):
    if "test_name" in doc:
        doc_name = doc["test_name"]
        benchmark_type = doc["test_name"].split("_")[0]
    else:
        doc_name = doc["experiment_id"]
        benchmark_type = "EXPERIMENT"

    for resource in plots:
        if resource not in plotted_resources:
            continue

        # Pre-Check for empty plot (no timeseries for all the metrics)
        empty_plot = True
        for metric in plots[resource]:
            metric_name = metric[0]
            if metric_name not in doc["users"][user] or doc["users"][user][metric_name]:
                empty_plot = False
        if empty_plot:
            eprint("Plot '{0}' for doc {1} has no data, skipping".format(resource, doc_name))
            continue

        fig = plt.figure(figsize=TIMESERIES_FIGURE_SIZE)
        ax1 = fig.add_subplot(111)

        #####################################################

        # Values used for setting the X and Y limits, without depending on actual time series values ####
        max_x_ts_point_value = 0
        if cfg.STATIC_LIMITS:
            max_y_ts_point_value = cfg.YLIM["default"][resource]
        else:
            max_y_ts_point_value = 0
        ###########################################################

        for metric in plots[resource]:
            metric_name = metric[0]
            user_resources = doc["users"][user]

            # Get the time series data
            if metric_name not in user_resources or not user_resources[metric_name]:
                continue

            ts = user_resources[metric_name]
            timeseries = cfg.bdwatchdog_handler.perform_timeseries_range_apply(ts, 0, None)

            # Convert the time stamps to times relative to 0 (basetime)
            basetime = int(list(timeseries.keys())[0])
            x = list(map(lambda point: int(point) - basetime, timeseries))

            y = list(timeseries.values())

            # Set the maximum time series  time and value points
            #max_y_ts_point_value = max(max_y_ts_point_value, max(y))
            max_x_ts_point_value = max(max_x_ts_point_value, max(x))

            # Plot a time series
            linestyle = line_style[resource][metric_name]

            ax1.plot(x, y,
                     label=translate_metric(metric_name),
                     linestyle=linestyle,
                     dashes=dashes_dict[linestyle],
                     marker=line_marker[resource][metric_name],
                     markersize=6,
                     markevery=5)

        # Set x and y limits
        top, bottom = max_y_ts_point_value, 0
        left, right = -30, max_x_ts_point_value + 30

        # If not static limits apply an amplification factor or the max timeseries value will be at the plot "ceiling"
        if not cfg.STATIC_LIMITS:
            top = int(float(top * cfg.Y_AMPLIFICATION_FACTOR))

        plt.xlim(left=left, right=right)
        plt.ylim(top=top, bottom=bottom)

        # Set properties to the whole plot
        plt.xlabel('Time(s)', fontsize=13)
        plt.ylabel(translate_plot_name_to_ylabel(resource), style="italic", weight="bold", fontsize=13)
        plt.title('')
        plt.grid(True)
        plt.legend(loc='upper right',
                   shadow=False,
                   fontsize='large',
                   fancybox=True,
                   facecolor='#afeeee',
                   labelspacing=0.15,
                   handletextpad=0.18,
                   borderpad=0.22)

        if cfg.STATIC_LIMITS:
            plt.xticks(np.arange(0, right, step=cfg.XTICKS_STEP))
        else:
            # May be inaccurate up to +- 'downsample' seconds,
            # because the data may start a little after the specified 'start' time or end
            # a little before the specified 'end' time
            plt.xticks(np.arange(0, int(end_time) - int(start_time), step=cfg.XTICKS_STEP))

        # Save the plot
        if "svg" in cfg.PLOTTING_FORMATS:
            figure_name = "{0}_{1}.{2}".format(user, resource, "svg")
            figure_filepath_directory = "{0}/{1}/{2}".format("timeseries_plots", benchmark_type, doc_name)
            save_figure(figure_filepath_directory, figure_name, fig, format="svg")

        # Save the plot
        if "png" in cfg.PLOTTING_FORMATS:
            figure_name = "{0}_{1}.{2}".format(user, resource, "png")
            figure_filepath_directory = "{0}/{1}/{2}".format("timeseries_plots", benchmark_type, doc_name)
            save_figure(figure_filepath_directory, figure_name, fig, format="png")
        plt.close()
