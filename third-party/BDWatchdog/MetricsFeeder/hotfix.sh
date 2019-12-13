#!/usr/bin/env bash
sed 's/w+t/wb+/g' /usr/local/lib/python3.6/dist-packages/daemon/runner.py -i
sed 's/w+t/wb+/g' /usr/local/lib/python3.6/site-packages/daemon/runner.py -i

