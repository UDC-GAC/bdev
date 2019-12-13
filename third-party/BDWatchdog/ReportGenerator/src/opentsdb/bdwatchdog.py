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


import requests
import json


class BDWatchdog:
    OPENTSDB_URL = "opentsdb"
    OPENTSDB_PORT = 4242
    NO_METRIC_DATA_DEFAULT_VALUE = 0  # -1

    def __init__(self, server=None):
        if not server:
            self.server = "http://{0}:{1}".format(self.OPENTSDB_URL, str(int(self.OPENTSDB_PORT)))
        else:
            self.server = server
        self.session = requests.Session()

    def get_points(self, query, tries=3):
        try:
            r = self.session.post(self.server + "/api/query", data=json.dumps(query),
                                  headers={'content-type': 'application/json', 'Accept': 'application/json'})
            if r.status_code == 200:
                return json.loads(r.text)
            else:
                r.raise_for_status()
        except requests.ConnectionError as e:
            tries -= 1
            if tries <= 0:
                raise e
            else:
                self.get_points(query, tries)

    def get_structure_timeseries(self, structure_name, start, end, retrieve_metrics, downsample=5):
        usages = dict()
        subquery = list()
        for metric in retrieve_metrics:
            metric_name = metric[0]
            metric_tag = metric[1]
            usages[metric_name] = dict()
            subquery.append(dict(aggregator='zimsum', metric=metric_name, tags={metric_tag: structure_name},
                                 downsample=str(downsample) + "s-avg"))

        query = dict(start=start, end=end, queries=subquery)
        result = self.get_points(query)

        for metric in result:
            dps = metric["dps"]
            metric_name = metric["metric"]
            usages[metric_name] = dps

        return usages

    @staticmethod
    def perform_hysteresis_aggregation(timeseries):
        hysteresis_count = 0
        points = list(timeseries.items())
        if points:
            # Perform the differentiation
            previous_time = int(points[0][0])
            previous_value = points[0][1]
            for point in points[1:]:
                time = int(point[0])
                value = point[1]
                diff_time = time - previous_time
                diff_value = abs(value - previous_value)
                hysteresis_count += diff_value / diff_time
                previous_time = time
                previous_value = value
        return hysteresis_count

    @staticmethod
    def perform_timeseries_range_apply(timeseries, ymin=0, ymax=None):
        check_range = True
        try:
            if ymin:
                int(ymin)
            if ymax:
                int(ymax)
            if (not ymax and ymin == 0) or ymin >= ymax:
                check_range = False
        except ValueError:
            check_range = False

        if check_range:
            points = list(timeseries.items())
            for point in points:
                key = point[0]
                value = point[1]
                if value > ymax:
                    timeseries[key] = ymax
                elif ymin and value < ymin:
                    timeseries[key] = ymin
        return timeseries

    @staticmethod
    def perform_check_for_missing_metric_info(timeseries, max_diff_time=30):
        misses = list()
        if timeseries:
            points = list(timeseries.items())
            previous_timestamp = int(points[0][0])
            for point in points[1:]:
                timestamp = int(point[0])
                diff_time = timestamp - previous_timestamp
                if diff_time >= max_diff_time:
                    misses.append({"time": previous_timestamp, "diff_time": diff_time})
                previous_timestamp = timestamp
        return misses

    @staticmethod
    def perform_structure_metrics_aggregations(start, end, metrics):
        usages = dict()
        for metric in metrics:
            summatory = 0
            points = list(metrics[metric].items())
            if points:
                # Perform the integration through trapezoidal steps
                previous_time = int(points[0][0])
                previous_value = points[0][1]
                for point in points[1:]:
                    time = int(point[0])
                    value = point[1]
                    diff_time = time - previous_time
                    added_value = value + previous_value
                    summatory += (added_value / 2) * diff_time
                    previous_time = time
                    previous_value = value
            average = summatory / (end - start)
            usages[metric] = dict()
            usages[metric]["AVG"] = average
            usages[metric]["SUM"] = summatory
        return usages
