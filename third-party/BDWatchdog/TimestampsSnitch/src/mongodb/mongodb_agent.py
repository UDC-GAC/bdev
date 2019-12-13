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
import requests
import json
import ast
import os


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


headers = {'content-type': 'application/json'}

default_mongodb_port = 8000
default_mongodb_ip = "mongodb"
default_tests_database_name = "tests"
default_experiments_database_name = "experiments"

MONGODB_IP_OS_VARNAME = "MONGODB_IP"
MONGODB_PORT_OS_VARNAME = "MONGODB_PORT"
TESTS_POST_ENDPOINT_OS_VARNAME = "TESTS_POST_ENDPOINT"
EXPERIMENTS_POST_ENDPOINT_OS_VARNAME = "EXPERIMENTS_POST_ENDPOINT"
post_doc_buffer_length = 1
MAX_CONNECTION_TRIES = 3


class MongoDBTimestampAgent:

    def __init__(self, os_env=None):
        if not os_env:
            self.tests_post_endpoint = os.getenv(TESTS_POST_ENDPOINT_OS_VARNAME, default_tests_database_name)
            self.experiments_post_endpoint = os.getenv(EXPERIMENTS_POST_ENDPOINT_OS_VARNAME,
                                                       default_experiments_database_name)
            self.mongodb_ip = os.getenv(MONGODB_IP_OS_VARNAME, default_mongodb_ip)
            try:
                self.mongodb_port = str(int(os.getenv(MONGODB_PORT_OS_VARNAME, default_mongodb_port)))
            except ValueError:
                eprint("Invalid port configuration, using default '" + str(default_mongodb_port) + "'")
                self.mongodb_port = str(default_mongodb_port)
        else:
            try:
                self.tests_post_endpoint = os_env[TESTS_POST_ENDPOINT_OS_VARNAME]
            except KeyError:
                self.tests_post_endpoint = default_tests_database_name
            try:
                self.experiments_post_endpoint = os_env[EXPERIMENTS_POST_ENDPOINT_OS_VARNAME]
            except KeyError:
                self.experiments_post_endpoint = default_experiments_database_name
            try:
                self.mongodb_ip = os_env[MONGODB_IP_OS_VARNAME]
            except KeyError:
                self.mongodb_ip = default_mongodb_ip
            try:
                self.mongodb_port = str(int(os_env[MONGODB_PORT_OS_VARNAME]))
            except (ValueError, KeyError):
                self.mongodb_port = str(default_mongodb_port)

        self.tests_full_endpoint = "http://{0}:{1}/{2}".format(self.mongodb_ip, self.mongodb_port,
                                                               self.tests_post_endpoint)

        self.experiments_full_endpoint = "http://{0}:{1}/{2}".format(self.mongodb_ip, self.mongodb_port,
                                                                     self.experiments_post_endpoint)

    def get_experiments_endpoint(self):
        return self.experiments_full_endpoint

    def get_tests_endpoint(self):
        return self.tests_full_endpoint

    @staticmethod
    def merge_data_from_existing_doc(old, new):
        for key in ["start_time", "end_time"]:
            try:
                if key not in new.keys():
                    new[key] = old[key]
            except KeyError:
                pass

        return new

    def post_doc(self, doc, info, endpoint):
        tries = 0
        while tries <= MAX_CONNECTION_TRIES:
            if info == {}:
                # Document doesn't exist, create
                r = requests.post(endpoint, headers=headers, data=json.dumps(doc))
                if r.status_code != 201:
                    eprint("[MONGODB AGENT] couldn't properly put document to address {0}".format(endpoint))
                    eprint(r.text)
                else:
                    print("Document created at: {0}".format(
                        time.strftime("%D %H:%M:%S", time.localtime()) + " timestamp is " + str(time.time())))
                    break
            else:
                # Test exists, update
                etag = info["_etag"]
                doc_id = info["_id"]

                doc = self.merge_data_from_existing_doc(info, doc)

                these_headers = headers
                these_headers["If-Match"] = etag
                r = requests.put(endpoint + "/" + str(doc_id), headers=these_headers,
                                 data=json.dumps(doc))
                if r.status_code != 200:
                    eprint("[MONGODB AGENT] couldn't properly put document to address {0}".format(endpoint))
                    eprint(r.text)
                else:
                    print("Document updated at: " + time.strftime("%D %H:%M:%S", time.localtime()))
                    break
        if tries > MAX_CONNECTION_TRIES:
            error_string = "Information posting for document {0} failed too many times, aborting".format(str(doc))
            eprint(error_string)
            raise ConnectionError(error_string)

    def experiment_exists(self, experiment_id, username):
        info = self.get_experiment(experiment_id, username)
        if info:
            return True
        return False

    def send_experiment_docs(self, documents):
        for experiment in documents:
            info = self.get_experiment(experiment["experiment_id"], experiment["username"])
            self.post_doc(experiment, info, self.experiments_full_endpoint)

    def send_test_docs(self, documents):
        for test in documents:
            if not self.experiment_exists(test["experiment_id"], test["username"]):
                # Experiment doesn't exist
                eprint("[SNITCH MONGODB AGENT] experiment {0} doesn't exist".format(test["experiment_id"]))
                continue
            info = self.get_test(test["experiment_id"], test["test_name"], test["username"])
            self.post_doc(test, info, self.tests_full_endpoint)

    def send_docs(self, documents):
        if len(documents["experiment"]) >= 1:
            self.send_experiment_docs(documents["experiment"])
        if len(documents["test"]) >= 1:
            self.send_test_docs(documents["test"])

    @staticmethod
    def get_legth_docs(documents):
        num_docs = 0
        for key in documents:
            num_docs += len(documents[key])
        return num_docs

    def delete_test(self, experiment_id, test_name, username):
        if self.experiment_exists(experiment_id, username):
            test = self.get_test(experiment_id, test_name, username)
            if not test:
                print("Document doesn't {0} exist".format(test_name))
                return
            headers["If-Match"] = test["_etag"]
            tests_full_endpoint = "{0}/{1}".format(self.tests_full_endpoint, test["_id"])
            r = requests.delete(tests_full_endpoint, headers=headers)
            if r.status_code != 204:
                eprint("[MONGODB AGENT] couldn't properly delete document to address {0}".format(tests_full_endpoint))
                eprint(r.text)
            else:
                print("Document deleted at: " + time.strftime("%D %H:%M:%S", time.localtime()))
        else:
            return False

    def delete_experiment(self, experiment_id, username):
        if self.experiment_exists(experiment_id, username):
            experiment = self.get_experiment(experiment_id, username)
            headers["If-Match"] = experiment["_etag"]
            experiment_full_endoint = "{0}/{1}".format(self.experiments_full_endpoint, experiment["_id"])
            r = requests.delete(experiment_full_endoint, headers=headers)
            if r.status_code != 204:
                eprint("[MONGODB AGENT] couldn't properly delete document in {0}".format(experiment_full_endoint))
                eprint(r.text)
            else:
                print("Document deleted at: " + time.strftime("%D %H:%M:%S", time.localtime()))
        else:
            eprint("Document doesn't {0} exist".format(experiment_id))
            return False

    def get_all_experiments(self, username):
        last_page = False
        all_experiments = list()
        host_endpoint = "http://{0}:{1}".format(self.mongodb_ip, self.mongodb_port)
        endpoint = "{0}/{1}".format(host_endpoint, self.experiments_post_endpoint) + \
                   "/?where=" + "{" + '"username":"' + username + '"}'
        while not last_page:
            data = self.get_paginated_docs(endpoint)
            if not data:
                return all_experiments
            num_page = data["_meta"]["page"]
            max_num_retrieved_experiments = num_page * data["_meta"]["max_results"]
            num_total_experiments = data["_meta"]["total"]
            if max_num_retrieved_experiments < num_total_experiments:
                endpoint = "{0}/{1}".format(host_endpoint, data["_links"]["next"]["href"])
            else:
                last_page = True
            all_experiments += data["_items"]
        return all_experiments

    def get_doc(self, endpoint, doc_name):
        tries = 0
        while tries <= MAX_CONNECTION_TRIES:
            status_code = None
            try:
                r = requests.get(endpoint)
                if r.status_code == 200:
                    experiments = r.json()["_items"]
                    if experiments:
                        return r.json()["_items"][0]
                    else:
                        return {}
                elif r.status_code == 404:
                    return {}
                else:
                    status_code = r.status_code
            except requests.ConnectionError as error:
                eprint("Error with request {0}".format(str(error)))
            eprint("Couldn't get document {0}, trying again for the {1} time out of {2}".format(
                doc_name, tries, MAX_CONNECTION_TRIES))
            if status_code:
                eprint("Status code was {0}".format(str(status_code)))
            tries += 1

        if tries > MAX_CONNECTION_TRIES:
            error_string = "Information retrieval for document {0} failed too many times, aborting".format(
                doc_name)
            eprint(error_string)
            raise requests.ConnectionError(error_string)

    def get_experiment(self, experiment_name, username):
        query = '?where={"experiment_id": "' + experiment_name + '","username":"' + username + '"}'
        endpoint = "{0}/{1}".format(self.experiments_full_endpoint, query)
        return self.get_doc(endpoint, experiment_name)

    def get_test(self, experiment_id, test_name, username):
        query = '?where={"experiment_id": "' + experiment_id + '", "test_name":"' + test_name + '","username":"' + username + '"}'
        endpoint = "{0}/{1}".format(self.tests_full_endpoint, query)
        return self.get_doc(endpoint, test_name)

    def get_experiment_tests(self, experiment_id, username):
        last_page = False
        all_tests = list()
        host_endpoint = "http://{0}:{1}".format(self.mongodb_ip, self.mongodb_port)
        endpoint = "{0}/{1}".format(host_endpoint, self.tests_post_endpoint) + \
                   '/?where={"experiment_id":"' + experiment_id + '", "username":"' + username + '"}'
        while not last_page:
            data = self.get_paginated_docs(endpoint)
            if not data:
                return all_tests
            num_page = data["_meta"]["page"]
            max_num_retrieved_experiments = num_page * data["_meta"]["max_results"]
            num_total_tests = data["_meta"]["total"]
            if max_num_retrieved_experiments < num_total_tests:
                endpoint = "{0}/{1}".format(host_endpoint, data["_links"]["next"]["href"])
            else:
                last_page = True
            all_tests += data["_items"]
        return all_tests

    @staticmethod
    def get_paginated_docs(endpoint):
        try:
            r = requests.get(endpoint)
            return r.json()
        except requests.ConnectionError as error:
            eprint("Error with request {0}".format(str(error)))
            return None


if __name__ == '__main__':
    abort = False

    docs = dict()
    docs["experiment"] = []
    docs["test"] = []

    agent = MongoDBTimestampAgent()

    eprint("[MONGODB AGENT] Mongodb agent started, waiting for input to send.")
    eprint("[MONGODB AGENT] Endpoints to use will be {0} to experiments and {1} to tests".format(
        agent.get_experiments_endpoint(), agent.get_tests_endpoint()
    ))

    try:
        # UNAFFECTED BY BUFFERING
        while True:
            line = sys.stdin.readline()

            if line == "":
                # Reached EOF
                break

            try:
                new_doc = ast.literal_eval(line)
                docs[new_doc["type"]] = docs[new_doc["type"]] + [new_doc["info"]]
            except ValueError:
                print("Error with document " + str(line))
                continue

            length_docs = agent.get_legth_docs(docs)
            if length_docs >= post_doc_buffer_length:
                agent.send_docs(docs)
                docs = dict()
                docs["experiment"] = []
                docs["test"] = []

                if abort:
                    exit(1)
                sys.stdout.flush()
        agent.send_docs(docs)
    except IOError as e:
        eprint("[MONGODB AGENT] terminated")
        eprint(e)
    except KeyboardInterrupt:
        eprint("[MONGODB AGENT] terminated")
        agent.send_docs(docs)
