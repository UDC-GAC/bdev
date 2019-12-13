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

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

for line in fileinput.input():
	stacks = ast.literal_eval(line)
	eprint("Number of stacks retrieved was : " + str(len(stacks)))
	for key in stacks:
		print(key + " " + str(float(stacks[key])))
