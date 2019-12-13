# Copyright (c) 2019 Universidade da Coruna
# Authors:
#     - Jonatan Enes [main](jonatan.enes@udc.es, jonatan.enes.alvarez@gmail.com)
#     - Roberto R. Exposito
#     - Juan Tourino
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

import fileinput
import sys
import json
import traceback
import requests
import gzip
from io import BytesIO
import time
import os
from requests.exceptions import ReadTimeout


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


# ENVIRONMENT VARIABLES #
POST_ENDPOINT_VARIABLE = "POST_ENDPOINT_PATH"
POST_DOC_BUFFER_LENGTH = "POST_DOC_BUFFER_LENGTH"
POST_DOC_BUFFER_TIMEOUT = "POST_DOC_BUFFER_TIMEOUT"
POST_SEND_DOCS_TIMEOUT = "POST_SEND_DOCS_TIMEOUT"
POST_SEND_DOCS_FAILED_TRIES = "POST_SEND_DOCS_FAILED_TRIES"

post_endpoint = os.getenv(POST_ENDPOINT_VARIABLE, 'http://opentsdb:4242/api/put')
post_doc_buffer_length = int(os.getenv(POST_DOC_BUFFER_LENGTH, 700))
post_doc_buffer_timeout = int(os.getenv(POST_DOC_BUFFER_TIMEOUT, 5))
post_send_docs_timeout = int(os.getenv(POST_SEND_DOCS_TIMEOUT, 3))
post_send_docs_failed_tries = int(os.getenv(POST_SEND_DOCS_FAILED_TRIES, 3))


def send_json_documents(json_documents, requests_Session=None):
    headers = {"Content-Type": "application/json", "Content-Encoding": "gzip"}

    out = BytesIO()
    with gzip.GzipFile(fileobj=out, mode="wb") as f:
        f.write(json.dumps(json_documents).encode())

    try:
        if requests_Session:
            r = requests_Session.post(post_endpoint, headers=headers, data=out.getvalue(),
                                      timeout=post_send_docs_timeout)
        else:
            r = requests.post(post_endpoint, headers=headers, data=out.getvalue(),
                              timeout=post_send_docs_timeout)
        if r.status_code != 204 and r.status_code != 400:
            return False, {"error": r.json()}
        else:
            if r.status_code == 400:
                return True, {}
                # return False, {"error": r.json()}
            return True, {}
    except ReadTimeout:
        return False, {"error": "Server timeout"}
    except Exception as e:
        return False, {"error": str(e)}


def process_line(line):
    new_doc = None
    try:
        new_doc = json.loads(line)
    except ValueError as e:
        if not line:
            eprint("[TSDB SENDER] Empty line was received")
        else:
            eprint("[TSDB SENDER] Error with document " + str(line))
            eprint(e)
    return new_doc


def finish(json_documents, requests_Session, message):
    success, info = send_json_documents(json_documents, requests_Session)
    sys.stdout.flush()
    eprint("[TSDB SENDER] -> {0}".format(message))
    exit(1)


def behave_like_pipeline():
    # PROGRAM VARIABLES #
    last_timestamp = time.time() - post_doc_buffer_timeout + 1
    failed_connections = 0
    fails = 0
    MAX_FAILS = 10
    abort = False
    json_documents = []
    requests_Session = requests.Session()
    try:
        for line in fileinput.input():
            new_doc = process_line(line)

            if not new_doc:
                fails += 1
                if fails >= MAX_FAILS:
                    message = "terminated due to too many read pipeline errors"
                    finish(json_documents, requests_Session, message)
                else:
                    continue
            else:
                json_documents = json_documents + [new_doc]
                fails = 0  # Reset fails

            current_timestamp = time.time()
            time_diff = current_timestamp - last_timestamp
            length_docs = len(json_documents)
            if length_docs >= post_doc_buffer_length or time_diff >= post_doc_buffer_timeout:
                last_timestamp = current_timestamp
                try:
                    success, info = send_json_documents(json_documents, requests_Session)
                    if not success:
                        eprint("[TSDB SENDER] couldn't properly post documents to address {0} error: {1}".format(
                            post_endpoint, str(info)))
                        failed_connections += 1
                    else:
                        print("Post was done at: " + time.strftime("%D %H:%M:%S", time.localtime()) + " with " + str(
                            length_docs) + " documents")
                        failed_connections = 0  # Reset failed connections, at least this one was successfull now
                        json_documents = []  # Empty document buffer
                except requests.exceptions.ConnectTimeout:
                    failed_connections += 1
                    eprint("[TSDB SENDER] couldn't send documents to address {0} and tried for {1} times".format(
                        post_endpoint, failed_connections))
                    if failed_connections >= post_send_docs_failed_tries:
                        abort = True

                if abort:
                    message = "terminated due to too connection errors"
                    finish(json_documents, requests_Session, message)

                sys.stdout.flush()
    except (KeyboardInterrupt, IOError) as e:
        # Exit silently
        eprint("[TSDB SENDER] terminated with error: " + str(e))
        track = traceback.format_exc()
        eprint(track)

    except Exception as e:
        eprint("[TSDB SENDER] terminated with error: " + str(e))
        track = traceback.format_exc()
        eprint(track)

    message = "finishing"
    finish(json_documents, requests_Session, message)


def main():
    behave_like_pipeline()


if __name__ == "__main__":
    main()
