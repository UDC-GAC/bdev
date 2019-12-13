#!/usr/bin/env python
import subprocess
import time


def get_devices():
    cmd = "ls /sys/class/infiniband/"
    result = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    devices = result.communicate()[0].strip().split('\n')
    return devices


def get_ports_of_device(device):
    cmd = "ls /sys/class/infiniband/" + device + "/ports/"
    result = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    ports = result.communicate()[0].strip().split('\n')
    return ports


def get_current_values(device, port):
    cmd = "cat /sys/class/infiniband/" + device + "/ports/" + port + "/counters/port_rcv_data"
    result = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    received = int(result.communicate()[0])

    cmd = "cat /sys/class/infiniband/" + device + "/ports/" + port + "/counters/port_xmit_data"
    result = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    sent = int(result.communicate()[0])
    return received, sent


def get_hostname():
    cmd = "hostname"
    result = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return result.communicate()[0].strip()


def get_timestamp():
    return int(time.time())


devices = get_devices()

info_dict = dict()
for device in devices:
    ports = get_ports_of_device(device)
    info_dict[device] = dict()
    info_dict[device]["ports_arr"] = ports
    info_dict[device]["ports"] = dict()
    for port in ports:
        info_dict[device]["ports"][port] = get_current_values(device, port)

hostname = get_hostname()
previous_timestamp = get_timestamp()
time.sleep(5)

while (1):
    for device in devices:
        ports = info_dict[device]["ports_arr"]
        for port in ports:
            previous_received, previous_sent = info_dict[device]["ports"][port]
            received, sent = get_current_values(device, port)
            print("INFINIBAND," + hostname + "," + str(get_timestamp()) + "," + str(
                get_timestamp() - previous_timestamp) + "," + device + "," + port + "," + str(
                received - previous_received) + "," + str(sent - previous_sent))
            info_dict[device]["ports"][port] = received, sent
    previous_timestamp = get_timestamp()

    time.sleep(5)
