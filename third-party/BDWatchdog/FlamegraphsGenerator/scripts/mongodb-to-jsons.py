#!/usr/bin/env python
from __future__ import print_function
import sys
import fileinput
from subprocess import call
import time 
import requests
import json
import os

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


default_mongodb_port = 5001
default_mongodb_ip = "mongodb"

MONGODB_IP = "MONGODB_IP"
mongodb_ip = os.getenv(MONGODB_IP, default_mongodb_ip)

MONGODB_PORT = "MONGODB_PORT"
try:
	mongodb_port = str(int(os.getenv(MONGODB_PORT, default_mongodb_port)))
except ValueError:
	eprint("Invalid port configuration, using default '" +  default_mongodb_port + "'")
	mongodb_port = str(default_mongodb_port)



def get_data(start_time, end_time):
    get_endpoint = 'http://' + mongodb_ip + ':' + mongodb_port + '/stacks/'
    payload = {'start_time': start_time, "end_time": end_time, "hostname": hostname}

    r = requests.get(get_endpoint, params=payload)
    if r.status_code != 200:
        eprint("COULDN'T GET DOCS")
        exit(1)
    else:
        print(json.dumps(r.json()))


if __name__ == "__main__":
    if len(sys.argv) < 4 :
        eprint("Missing arguments, at least two timestamps and a hostname are needed, first one will be start time and seconds one will be end time")
        exit(1)
    try:
		start_time = int(sys.argv[1])
		end_time = int(sys.argv[2])
		hostname = sys.argv[3]
    except ValueError:
		eprint("Parameters must be integers, in fact UNIX Timestamps, and a hostname or ALL for all hosts")
		exit(1)

    get_data(start_time, end_time)

