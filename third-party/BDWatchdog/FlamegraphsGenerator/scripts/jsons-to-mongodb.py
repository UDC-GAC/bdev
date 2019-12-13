#!/usr/bin/env python
from __future__ import print_function
import sys
import fileinput
from subprocess import call
import socket
import time 
import requests
import json
import ast
import os

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


default_mongodb_port = 8000
default_mongodb_ip = "mongodb"
default_profiling_database_name = "cpu"

MONGODB_IP = "MONGODB_IP"
mongodb_ip = os.getenv(MONGODB_IP, default_mongodb_ip)

MONGODB_PORT = "MONGODB_PORT"
try:
	mongodb_port = str(int(os.getenv(MONGODB_PORT, default_mongodb_port)))
except ValueError:
	eprint("Invalid port configuration, using default '" +  default_mongodb_port + "'")
	mongodb_port = str(default_mongodb_port)


PROFILING_POST_ENDPOINT = "PROFILING_POST_ENDPOINT"
profiling_post_endpoint = os.getenv(PROFILING_POST_ENDPOINT, default_profiling_database_name)


max_failed_connection_tries = 4
post_doc_buffer_length = 10000
post_endpoint = 'http://' + mongodb_ip + ':' + mongodb_port + '/' +profiling_post_endpoint 

def send_docs(docs):
    headers = {'content-type': 'application/json'}
    
    try:
		r = requests.post(post_endpoint, headers=headers,data=json.dumps(docs))
		if r.status_code != 201 :
			eprint("[MONGODB SENDER] couldn't properly post documents to address " + post_endpoint)
			eprint(r.text)
			return False
		else:
			print ("Post was done at: " +  time.strftime("%D %H:%M:%S", time.localtime()) + " with " + str(len(docs)) + " documents , timestamp is " + str(time.time()))
			return True
    except requests.exceptions.ConnectionError as e:
		eprint("[MONGODB SENDER] couldn't properly post documents to address " + post_endpoint)
		eprint(e)
		return False

failed_connections = 0
json_documents = []
try:
    for line in fileinput.input():
        try:
            new_doc = ast.literal_eval(line)
            json_documents = json_documents + [new_doc]
        except ValueError:
            print ("Error with document " + str(line))
            continue

        length_docs = len(json_documents)
        if(length_docs >= post_doc_buffer_length):
            if (not send_docs(json_documents)):
                    failed_connections += 1
            json_documents = []
            
            if (failed_connections >= max_failed_connection_tries):
                eprint("[MONGODB SENDER] couldn't send documents to address " + post_endpoint + " and tried for " + str(failed_connections) + " times, aborting")
                exit(1)
            sys.stdout.flush()
    send_docs(json_documents)
except IOError as e:
    eprint("[MONGODB SENDER] terminated")
    eprint(e)
    pass
except (KeyboardInterrupt):
    eprint("[MONGODB SENDER] terminated")
    pass
