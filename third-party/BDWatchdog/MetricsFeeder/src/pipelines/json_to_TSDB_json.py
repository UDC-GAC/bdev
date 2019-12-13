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

import fileinput
import sys
import json
import re


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def process_string(string):
    string = string.replace("(", "")
    string = string.replace(")", "")
    m = re.search(r"([A-Za-z0-9_,:\\/\s]+)", string)
    matched = m.group(1)
    pat_list = re.findall("\w+", matched)
    # If there are multiple words
    if len(pat_list) > 1:
        new_match = matched
        new_match = new_match.replace("[", "")
        new_match = new_match.replace("]", "")
        new_match = new_match.replace("{", "")
        new_match = new_match.replace("}", "")
        new_match = new_match.replace("-", "_hyphen_")
        new_match = new_match.replace("=", "_equals_")
        new_match = new_match.replace(".", "_dot_")
        new_match = new_match.replace("*", "_asterisk_")
        new_match = new_match.replace(">", "_right_arrow_")
        new_match = new_match.replace("<", "_left_arrow_")
        new_match = new_match.replace(",", "_comma_")
        new_match = new_match.replace(":", "_twodot_")
        new_match = new_match.replace("/", "_slash_")
        new_match = new_match.replace(" ", "_space_")
        string = string.replace(matched, new_match)
    return string


def process_line(line):
    if not line:
        return
    document = json.loads(line)
    try:
        for string in ["command", "host"]:
            if string in document["tags"]:
                document["tags"][string] = process_string(document["tags"][string])

        return json.dumps(document)
    except Exception:
        # If any error, just dump the original document
        return json.dumps(document)


def behave_like_pipeline():
    try:
        for line in fileinput.input():
        #while True:
        #    line = sys.stdin.readline()
            result = process_line(line)
            if result:
                print(result)
    except (KeyboardInterrupt, IOError):
        # Exit silently
        pass
    except Exception as e:
        eprint("[JSON TO VALID_JSON] error: " + str(e))


def main():
    behave_like_pipeline()


if __name__ == "__main__":
    main()
