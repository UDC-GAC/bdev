#!/usr/bin/python
# uniq.py

import sys
import os

cmptid=-1
count=0
key=-1
line=""
sys.stdout.softspace=False;
for cur_line in sys.stdin:
  cur_line = cur_line.strip()
  if(cur_line==""):
    if(count>0):
      print line,"\t",count
      count=0
      line=""

  if(cur_line != line):
    if(count>0):
      print line, "\t", count
      sys.stdout.flush()
    line=cur_line
    count = 1
  else:
    count += 1

if(count>0):
  print line,"\t",count

