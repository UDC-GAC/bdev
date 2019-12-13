# Metrics Feeder
This repository provides a series of scripts and daemons to parse the output of programs like **atop**, **nethogs** and **turbostat** and create a timeseries of metrics that can be stored in a file or fed into a timeseries database like **OpenTSDB**.
* With _**atop**_, resources (cpu, memory, disk and network) can be collected system-wise and process-wise.
* With _**nethogs**_, network usages can be collected pocess-wise.
* With _**turbostat**_, system power consumption (Watts) and temperature (cpu temp in ºC) can be collected.

Using a linux pipeline approach metrics can be collected, processed and optionally sent in real-time with a very low cpu processing and memory footprint. If stored, disk usage (size of resulting files) is to be considered, which makes the use of a timeseries database preferable.

## Requirements

#### System
In order to install some of these tools, such as atop, or to later use them, some basic packages are needed. These packages have not been included in the installation scripts to avoid installing or upgrading unwanted packages, as they are used by many other programs and system utilities. Currently, they are:
* A python flavor or a python running environment overall
* Basic development and building tools such as make or gcc. In ubuntu, these are grouped together in the build-essential package.

#### [atop](http://www.atoptool.nl/downloadatop.php)
To collect system resource metrics, atop is used.
* To atop, you can use the 'install-atop' script
* The scripts have been tested with atop 2.3.0 on several *Ubuntu 16.04 LTS* Linux flavours and on *CentOS 7 1511* 

:exclamation: _**When installed, the atop source code is compiled against the currently used kernel headers. If the kernel is updated, you may need to reinstall atop.**_ :exclamation:

#### [netatop](http://www.atoptool.nl/downloadnetatop.php) (Optional)
In order to have per-process network metrics, the netatop module is needed.
* To install this module, you can use the 'install-netatop' script
* If no metrics are shown but netatop was previously installed and working, make sure the module is loaded with
```
sudo modprobe netatop
```
* The scripts have been tested with netatop 1.0 on several Ubuntu 16.04 LTS Linux flavours and on *CentOS 7 1511*

:exclamation: _**The netatop module requires to be loaded to show per-process statistics with netatop. This requires admin priviledges as shown with the 'sudo' displayed in the command above.**_ :exclamation:

:exclamation: _**When installed, the netatop source code is compiled against the currently used kernel headers. If the kernel is updated, you may need to reinstall atop.**_ :exclamation:

#### [turbostat](https://github.com/torvalds/linux/blob/master/tools/power/x86/turbostat/turbostat.c)
To collect system power and temperature metrics, turbostat is needed.
* To install turbostat, you can use the 'install-turbostat' script
* The scripts have been tested with turbostat 4.12 on several flavors of Ubuntu 16.04 LTS Linux.

* :exclamation: _**Turbostat may require some tweaking of kernel variables to be executed without root priviledges. Run the allow_turbostat.sh script in the scripts folder to set these variables.**_ :exclamation:

* :exclamation: _**Turbostat only works in newer cpus that support the RAPL library, mainly Intel cpus newer than Sandy Bridge. Consult (http://web.eece.maine.edu/~vweaver/projects/rapl/rapl_support.html)**_ :exclamation:


#### [OpenTSDB](https://github.com/OpenTSDB/opentsdb/releases)
To store the metrics, a timeseries database is used, currently OpenTSDB version 2.3.0. 
</br>
Configure the daemon with the atop_config.ini file to send the metrics to the appropiate database endpoint

## Download and install
```
git clone https://github.com/JonatanEnes/BDWatchdog
cd BDWatchdog/MetricsFeeder
```
* On Ubuntu 16.04 and 18.04:
```
cd scripts/installation
bash install_in_ubuntu.sh
```

* On CentOS 7:
```
cd scripts/installation
bash install_in_centos7.sh
```

* On both Ubuntu and CentOS 7:
```
pip3 install -r requirements.txt
```

* If the daemon python package shows the next error:
```
Traceback (most recent call last):
  File "src/daemons/atop.py", line 154, in <module>
    serv = runner.DaemonRunner(app)
  File "/usr/local/lib/python3.6/dist-packages/daemon/runner.py", line 114, in __init__
    self._open_streams_from_app_stream_paths(app)
  File "/usr/local/lib/python3.6/dist-packages/daemon/runner.py", line 135, in _open_streams_from_app_stream_paths
    app.stderr_path, 'w+t', buffering=0)
ValueError: can't have unbuffered text I/O
```
Apply the next hotfix:
```
[Ubuntu] sed 's/w+t/wb+/g' /usr/local/lib/python3.6/dist-packages/daemon/runner.py -i
[CentOS] sed 's/w+t/wb+/g' /usr/local/lib/python3.6/site-packages/daemon/runner.py -i
```

## Usage

Most of the scripts can be used by piping them, some examples of linux pipelines are found in the scripts folder, but for user convenience an orquestrator daemon is provided.

#### Atop (system resource metrics)

To run the general resource system metric monitoring, you can start the atop daemon with: 
```
python3 src/daemons/atop.py start
```

Daemon configuration is stored in the conf/atop_conf.ini with a .ini format. 
</br>
Currently the most important configuration parameters to run the atop daemon are:
```
POST_ENDPOINT_PATH : REST endpoint to be used to send data to the OpenTSDB database [http://opentsdb:4242/api/put]
METRICS : metrics to be samples from atop [CPU,cpu,MEM,SWP,DSK,NET,PRC,PRM,PRD,PRN]
ATOP_SAMPLING_FREQUENCY : atop sampling, the number of seconds between polling [5]
POST_DOC_BUFFER_TIMEOUT : timeout to send metrics (max time to wait before sending docs) [10]
JAVA_TRANSLATION_ENABLED: whether to use Java translation or not for the java running machines that appear as "(java)" processes. [false]
```
These parameters can be tuned to select the number and size of data to be collected (metrics and polling time) and to choose between pushing for a more real-time or batch scenario (polling time and metrics timeout/buffer). They acan also be used to turn on or off the Java translation capabilities.

#### Turbostat (System power consumption and temperature)
To run the processor energy and temperature measurement with Turbostat, you can run the daemon with:
```
python3 src/daemons/turbostat.py start
```

Daemon configuration is stored in the conf/turbostat_conf.ini with a .ini format. 
</br>
Currently the most important configuration parameters to run the turbostat daemon are:
```
POST_ENDPOINT_PATH : REST endpoint to be used to send data to the OpenTSDB database [http://opentsdb:4242/api/put]
TURBOSTAT_SAMPLING_FREQUENCY : turbostat sampling, the number of seconds between polling [5]
POST_DOC_BUFFER_TIMEOUT : timeout to send metrics (max time to wait before sending docs) [10]
```
Like with the atop daemon, these parameters target a more real-time scenario or a batch oriented one.

## Examples

### Plotting timeseries
* To plot the metrics data, a simple script is provided to query directly for the generated gnuplot graphs to the OpenTSDB.
Run the draw_all script to query for all system metrics (CPU, Memory, Disk, Network, Power and Temperature):
```
bash scripts/draw_all.sh
```
* Examples of all the metrics plots for a slave host running a short batch of Hadoop MapReduce task (TeraGen,TeraSort, TeraValidate and Pi)are shown below:

![alt tag](https://s3-eu-west-1.amazonaws.com/jonatan.enes.udc/bdwatchdog_website/cpu_timeseries.png)
![alt tag](https://s3-eu-west-1.amazonaws.com/jonatan.enes.udc/bdwatchdog_website/mem_timeseries.png)
![alt tag](https://s3-eu-west-1.amazonaws.com/jonatan.enes.udc/bdwatchdog_website/disk_timeseries.png)
![alt tag](https://s3-eu-west-1.amazonaws.com/jonatan.enes.udc/bdwatchdog_website/net_timeseries.png)

* Examples of measurements of a server and its power and temperature are show below:

![alt tag](https://s3-eu-west-1.amazonaws.com/jonatan.enes.udc/bdwatchdog_website/temp_timeseries.png)
![alt tag](https://s3-eu-west-1.amazonaws.com/jonatan.enes.udc/bdwatchdog_website/power_timeseries.png)

### Atop (System resource metrics)
* Running atop raw, the ouput would look something like this (output was reduced, lines were omitted):
```
atop 5 -P cpu,PRC,PRM,PRD,PRN
```
```
SEP
cpu testMachine 1491471847 2017/04/06 11:44:07 5 100 0 0 0 0 500 0 0 0 0 0 4007 100
cpu testMachine 1491471847 2017/04/06 11:44:07 5 100 1 0 0 0 498 0 0 0 0 0 4007 100
PRC testMachine 1491471847 2017/04/06 11:44:07 5 1 (systemd) S 100 0 0 0 120 0 0 0 0 1 y
PRC testMachine 1491471847 2017/04/06 11:44:07 5 2 (kthreadd) S 100 0 0 0 120 0 0 1 0 2 y
PRC testMachine 1491471847 2017/04/06 11:44:07 5 851 (in:imklog) S 100 0 0 0 120 0 0 1 0 812 n
PRC testMachine 1491471847 2017/04/06 11:44:07 5 852 (rs:main Q:Reg) S 100 0 0 0 120 0 0 1 0 812 n
PRC testMachine 1491471847 2017/04/06 11:44:07 5 813 (atd) S 100 0 0 0 120 0 0 0 0 813 y
PRC testMachine 1491471847 2017/04/06 11:44:07 5 817 (dbus-daemon) S 100 0 0 0 120 0 0 1 0 817 y
PRC testMachine 1491471847 2017/04/06 11:44:07 5 855 (systemd-logind) S 100 0 0 0 120 0 0 1 0 855 y
PRC testMachine 1491471847 2017/04/06 11:44:07 5 883 (dhclient) S 100 0 0 0 120 0 0 0 0 883 y
PRC testMachine 1491471847 2017/04/06 11:44:07 5 894 (cron) S 100 0 0 0 120 0 0 0 0 894 y
PRC testMachine 1491471847 2017/04/06 11:44:07 5 901 (accounts-daemon) S 100 0 0 0 120 0 0 1 0 901 y
PRC testMachine 1491471847 2017/04/06 11:44:07 5 901 (accounts-daemon) S 100 0 0 0 120 0 0 1 0 901 n
PRC testMachine 1491471847 2017/04/06 11:44:07 5 944 (gmain) S 100 0 0 0 120 0 0 1 0 901 n
PRC testMachine 1491471847 2017/04/06 11:44:07 5 951 (gdbus) S 100 0 0 0 120 0 0 0 0 901 n
PRC testMachine 1491471847 2017/04/06 11:44:07 5 905 (acpid) S 100 0 0 0 120 0 0 1 0 905 y
PRM testMachine 1491471847 2017/04/06 11:44:07 5 8 (rcu_bh) S 4096 0 0 0 0 0 0 0 0 0 0 0 8 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 9 (migration/0) S 4096 0 0 0 0 0 0 0 0 0 0 0 9 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 10 (watchdog/0) S 4096 0 0 0 0 0 0 0 0 0 0 0 10 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 11 (watchdog/1) S 4096 0 0 0 0 0 0 0 0 0 0 0 11 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 12 (migration/1) S 4096 0 0 0 0 0 0 0 0 0 0 0 12 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 13 (ksoftirqd/1) S 4096 0 0 0 0 0 0 0 0 0 0 0 13 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 15 (kworker/1:0H) S 4096 0 0 0 0 0 0 0 0 0 0 0 15 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 16 (kdevtmpfs) S 4096 0 0 0 0 0 0 0 0 0 0 0 16 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 17 (netns) S 4096 0 0 0 0 0 0 0 0 0 0 0 17 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 1227 ((sd-pam)) S 4096 61444 2128 1392 0 0 0 0 4260 2008 136 0 1227 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 1261 (sshd) S 4096 95372 3372 764 0 0 0 0 8740 752 136 0 1261 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 1262 (bash) S 4096 22696 5456 976 0 0 0 0 2308 1892 136 0 1262 y
PRM testMachine 1491471847 2017/04/06 11:44:07 5 7870 (knetatop) S 4096 0 0 0 0 0 0 0 0 0 0 0 7870 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 7885 (kworker/u4:2) S 4096 0 0 0 0 0 0 0 0 0 0 0 7885 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 8889 (atop) R 4096 23796 7248 196 284 264 71 0 3512 3476 136 0 8889 y 0
PRM testMachine 1491471847 2017/04/06 11:44:07 5 8890 (atop) E 4096 0 0 0 0 0 1 0 0 0 0 0 8890 y 0
PRD testMachine 1491471847 2017/04/06 11:44:07 5 1 (systemd) S n y 0 0 0 0 0 1 n y
PRD testMachine 1491471847 2017/04/06 11:44:07 5 2 (kthreadd) S n y 0 0 0 0 0 2 n y
PRD testMachine 1491471847 2017/04/06 11:44:07 5 3 (ksoftirqd/0) S n y 0 0 0 0 0 3 n y
PRD testMachine 1491471847 2017/04/06 11:44:07 5 5 (kworker/0:0H) S n y 0 0 0 0 0 5 n y
PRD testMachine 1491471847 2017/04/06 11:44:07 5 7 (rcu_sched) S n y 0 0 0 0 0 7 n y
PRD testMachine 1491471847 2017/04/06 11:44:07 5 8 (rcu_bh) S n y 0 0 0 0 0 8 n y
PRD testMachine 1491471847 2017/04/06 11:44:07 5 35 (vmstat) S n y 0 0 0 0 0 35 n y
PRD testMachine 1491471847 2017/04/06 11:44:07 5 1227 ((sd-pam)) S n y 0 0 0 0 0 1227 n y
PRD testMachine 1491471847 2017/04/06 11:44:07 5 8889 (atop) R n y 0 0 0 0 0 8889 n y
PRD testMachine 1491471847 2017/04/06 11:44:07 5 8890 (atop) E n y 0 0 0 0 0 8890 n y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 1 (systemd) S y 0 0 0 0 0 0 0 0 0 0 1 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 2 (kthreadd) S y 0 0 0 0 0 0 0 0 0 0 2 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 3 (ksoftirqd/0) S y 0 0 0 0 0 0 0 0 0 0 3 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 5 (kworker/0:0H) S y 0 0 0 0 0 0 0 0 0 0 5 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 7 (rcu_sched) S y 0 0 0 0 0 0 0 0 0 0 7 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 8 (rcu_bh) S y 0 0 0 0 0 0 0 0 0 0 8 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 9 (migration/0) S y 0 0 0 0 0 0 0 0 0 0 9 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 10 (watchdog/0) S y 0 0 0 0 0 0 0 0 0 0 10 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 11 (watchdog/1) S y 0 0 0 0 0 0 0 0 0 0 11 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 12 (migration/1) S y 0 0 0 0 0 0 0 0 0 0 12 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 13 (ksoftirqd/1) S y 0 0 0 0 0 0 0 0 0 0 13 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 15 (kworker/1:0H) S y 0 0 0 0 0 0 0 0 0 0 15 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 16 (kdevtmpfs) S y 0 0 0 0 0 0 0 0 0 0 16 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 1035 (sshd) S y 0 0 0 0 0 0 0 0 0 0 1035 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 1261 (sshd) S y 25 53678 32 2300 0 0 0 0 0 0 1261 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 1262 (bash) S y 0 0 0 0 0 0 0 0 0 0 1262 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 8889 (atop) R y 0 0 0 0 0 0 0 0 0 0 8889 y
PRN testMachine 1491471847 2017/04/06 11:44:07 5 8890 (atop) E y 0 0 0 0 0 0 0 0 0 0 8890 y
SEP
```

* Running manually (without using the daemon) part of the pipeline (without sending the data to OpenTSDB), collecting metrics for cpu system-wise and cpu, memory, disk and net process-wise, with 5 seconds windows, the output would look like this:
```
export PYTHONUNBUFFERING="yes" #Tell python to unbuffer so that output shows up sooner
atop 5 -P cpu,PRC,PRM,PRD,PRN | ./pipes/atop_to_csv.py | ./pipes/field_filter.py \
| ./pipes/validator.py | ./pipes/custom_filter.py | ./pipes/field_translator.py | ./pipes/value_filter.py \
| ./pipes/csv_to_json.py
```
```
{"metric": "proc.cpu.user","timestamp":"1491472173","value": "0.00","tags": {"host":"testMachine","pid":"8900","command":"(atop)","state":"R"}}
{"metric": "proc.cpu.kernel","timestamp":"1491472173","value": "0.20","tags": {"host":"testMachine","pid":"8900","command":"(atop)","state":"R"}}
{"metric": "proc.cpu.user","timestamp":"1491472173","value": "0.00","tags": {"host":"testMachine","pid":"8901","command":"(python)","state":"S"}}
{"metric": "proc.cpu.kernel","timestamp":"1491472173","value": "0.20","tags": {"host":"testMachine","pid":"8901","command":"(python)","state":"S"}}
{"metric": "proc.cpu.user","timestamp":"1491472173","value": "0.00","tags": {"host":"testMachine","pid":"8902","command":"(python)","state":"S"}}
{"metric": "proc.cpu.kernel","timestamp":"1491472173","value": "0.20","tags": {"host":"testMachine","pid":"8902","command":"(python)","state":"S"}}
{"metric": "proc.cpu.user","timestamp":"1491472173","value": "0.20","tags": {"host":"testMachine","pid":"8905","command":"(python)","state":"S"}}
{"metric": "proc.cpu.kernel","timestamp":"1491472173","value": "0.00","tags": {"host":"testMachine","pid":"8905","command":"(python)","state":"S"}}
{"metric": "proc.mem.virtual","timestamp":"1491472173","value": "133.15","tags": {"host":"testMachine","pid":"907","command":"(snapd)","state":"S"}}
{"metric": "proc.mem.resident","timestamp":"1491472173","value": "12.16","tags": {"host":"testMachine","pid":"907","command":"(snapd)","state":"S"}}
{"metric": "proc.mem.swap","timestamp":"1491472173","value": "0.00","tags": {"host":"testMachine","pid":"907","command":"(snapd)","state":"S"}}
{"metric": "sys.cpu.kernel","timestamp":"1491472178","value": "0.00","tags": {"host":"testMachine","core":"0"}}
{"metric": "sys.cpu.user","timestamp":"1491472178","value": "0.20","tags": {"host":"testMachine","core":"0"}}
{"metric": "sys.cpu.idle","timestamp":"1491472178","value": "99.80","tags": {"host":"testMachine","core":"0"}}
{"metric": "sys.cpu.wait","timestamp":"1491472178","value": "0.00","tags": {"host":"testMachine","core":"0"}}
{"metric": "sys.cpu.kernel","timestamp":"1491472178","value": "0.20","tags": {"host":"testMachine","core":"1"}}
{"metric": "sys.cpu.user","timestamp":"1491472178","value": "0.20","tags": {"host":"testMachine","core":"1"}}
{"metric": "sys.cpu.idle","timestamp":"1491472178","value": "99.80","tags": {"host":"testMachine","core":"1"}}
{"metric": "sys.cpu.wait","timestamp":"1491472178","value": "0.00","tags": {"host":"testMachine","core":"1"}}
{"metric": "proc.cpu.user","timestamp":"1491472178","value": "0.00","tags": {"host":"testMachine","pid":"8900","command":"(atop)","state":"R"}}
{"metric": "proc.cpu.kernel","timestamp":"1491472178","value": "0.20","tags": {"host":"testMachine","pid":"8900","command":"(atop)","state":"R"}}
{"metric": "proc.cpu.user","timestamp":"1491472178","value": "0.20","tags": {"host":"testMachine","pid":"8903","command":"(python)","state":"S"}}
{"metric": "proc.cpu.kernel","timestamp":"1491472178","value": "0.00","tags": {"host":"testMachine","pid":"8903","command":"(python)","state":"S"}}
{"metric": "proc.mem.virtual","timestamp":"1491472178","value": "133.15","tags": {"host":"testMachine","pid":"907","command":"(snapd)","state":"S"}}
{"metric": "proc.mem.resident","timestamp":"1491472178","value": "12.16","tags": {"host":"testMachine","pid":"907","command":"(snapd)","state":"S"}}
{"metric": "proc.mem.swap","timestamp":"1491472178","value": "0.00","tags": {"host":"testMachine","pid":"907","command":"(snapd)","state":"S"}}
```
Output is significantly reduce because most of the process do not use actively resources (zero or very near to zero usage) and are thus filtered.

* To send it to the OpenTSDB, just append the missing pipelines:
```
export PYTHONUNBUFFERING="yes" #Tell python to unbuffer so that output shows up sooner
atop 5 -P CPU,cpu,MEM,SWP,DSK,NET,PRC,PRM,PRD,PRN | ./pipes/atop_to_csv.py | ./pipes/field_filter.py \
| ./pipes/validator.py | ./pipes/custom_filter.py | ./pipes/field_translator.py | ./pipes/value_filter.py \
| ./pipes/csv_to_json.py | ./pipes/json_to_TSDB_json.py | ./pipes/send_to_OpenTSDB.py
```

### Turbostat (System power consumption and temperature)
* Running turbostat raw, the ouput would look something like this:
```
turbostat --debug --interval 5 --processor
```

```
    Core     CPU Avg_MHz   Busy% Bzy_MHz TSC_MHz     IRQ     SMI  CPU%c1  CPU%c3  CPU%c6  CPU%c7 CoreTmp  PkgTmp GFX%rc6  GFXMHz Totl%C0  Any%C0  GFX%C0 CPUGFX% Pkg%pc2 Pkg%pc3 Pkg%pc6 Pkg%pc7 Pkg%pc8 Pkg%pc9 Pk%pc10 PkgWatt RAMWatt   PKG_%   RAM_%
       -       -     909   37.76    2407    2592    5069       0    9.01    0.13    6.56   46.42      59      59   99.57     300   85.56   49.07    0.37    0.12   44.02    0.00    0.00    0.00    0.00    0.00    0.00    5.03    0.52    0.00    0.00
       0       0     906   37.35    2426    2592    1246       0    8.55    0.07    6.49   47.42      58      59   99.57     300   85.56   49.07    0.37    0.12   44.02    0.00    0.00    0.00    0.00    0.00    0.00    5.03    0.52    0.00    0.00
       1       1     907   37.56    2415    2592     983       0   10.08    0.19    6.63   45.43      59
```
* Running turbostat with a partial pipeline, without sending the data to OpenTSDB, the output looks like this:
```
turbostat --interval 2 --debug --processor 2>/dev/null | sed -u -e 's/^[ \t]*//' | sed -u -e "s/[[:space:]]\+/,/g" | python turbostat_to_csv.py | python ./pipes/csv_to_json.py
```
```
"metric": "sys.processors.temp","timestamp":"1491486444","value": "45","tags": {"host":"jonatan-DES-GAC-portatil"}}
{"metric": "sys.processors.energy","timestamp":"1491486444","value": "7.14","tags": {"host":"jonatan-DES-GAC-portatil"}}
{"metric": "sys.cpu.temp","timestamp":"1491486444","value": "45","tags": {"host":"jonatan-DES-GAC-portatil","cpu":"0"}}
{"metric": "sys.cpu.energy","timestamp":"1491486444","value": "7.14","tags": {"host":"jonatan-DES-GAC-portatil","cpu":"0"}}
{"metric": "sys.core.temp","timestamp":"1491486444","value": "43","tags": {"host":"jonatan-DES-GAC-portatil","core":"0"}}
{"metric": "sys.core.temp","timestamp":"1491486444","value": "44","tags": {"host":"jonatan-DES-GAC-portatil","core":"1"}}
{"metric": "sys.processors.temp","timestamp":"1491486446","value": "61","tags": {"host":"jonatan-DES-GAC-portatil"}}
{"metric": "sys.processors.energy","timestamp":"1491486446","value": "10.97","tags": {"host":"jonatan-DES-GAC-portatil"}}
{"metric": "sys.cpu.temp","timestamp":"1491486446","value": "61","tags": {"host":"jonatan-DES-GAC-portatil","cpu":"0"}}
{"metric": "sys.cpu.energy","timestamp":"1491486446","value": "10.97","tags": {"host":"jonatan-DES-GAC-portatil","cpu":"0"}}
{"metric": "sys.core.temp","timestamp":"1491486446","value": "60","tags": {"host":"jonatan-DES-GAC-portatil","core":"0"}}
{"metric": "sys.core.temp","timestamp":"1491486446","value": "61","tags": {"host":"jonatan-DES-GAC-portatil","core":"1"}}
{"metric": "sys.processors.temp","timestamp":"1491486448","value": "46","tags": {"host":"jonatan-DES-GAC-portatil"}}
{"metric": "sys.processors.energy","timestamp":"1491486448","value": "3.80","tags": {"host":"jonatan-DES-GAC-portatil"}}

```
* To send it to the OpenTSDB, just append the missing pipelines:

```
turbostat --interval 2 --debug --processor 2>/dev/null | sed -u -e 's/^[ \t]*//' | sed -u -e "s/[[:space:]]\+/,/g" | python ./pipes/turbostat_to_csv.py | python ./pipes/csv_to_json.py | ./pipes/json_to_TSDB_json.py | ./pipes/send_to_OpenTSDB.py
```
