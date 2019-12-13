#!/usr/bin/env python
from __future__ import print_function
import sys
import fileinput
from subprocess import call
import socket
import time 
import json
import os


TIMESTAMP = "TIMESTAMP"
try:
	timestamp = int(os.getenv(TIMESTAMP, time.time()))
except(ValueError):
	timestamp = time.time()

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


max_stack_depth = 40
min_stack_value = 5

hostname = socket.gethostname()
#timestamp = int(time.time())
docs = list()
try:
	for line in fileinput.input():
		fields = line.split(" ")
		key = ("_").join(fields[0:len(fields)-1])
		
		try:
			value = int(float(fields[-1].strip()))
		except(ValueError):
			eprint(line)
			continue

		stack_depth = len(key.split(";"))

		if not (stack_depth > max_stack_depth and value < min_stack_value):
			#print(line.strip())
			
			document = dict()
			document["timestamp"] = timestamp 
			document["hostname"] = hostname 
			document["stack"] = key
			document["value"] = value

			print(json.dumps(document))
			
except IOError as e:
	eprint(e)
	exit(1)
except KeyboardInterrupt as e:
	eprint(e)
	exit(0)
