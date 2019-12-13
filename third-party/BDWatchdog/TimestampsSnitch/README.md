# Timestamps Snitch
This subproject provides a simple tool to manage experiments and tests
'start' and 'end' UNIX timestamps, considering that an experiment 
encompasses several tests.

The timestamps can be used for a variety of use cases, in particular
they have been integrated with the TimeseriesViewer and the 
ReportGenerator subprojects of BDWatchdog, to handle the generation of 
time series plots and reports, respectively.

## Download and install
```
git clone https://github.com/JonatanEnes/BDWatchdog/
cd BDWatchdog/TimestampsSnitch/
bash scripts/install/ubuntu/install-mongodb-dependencies.sh
pip3 install -r requirements.txt
```
##### Requirements
In order to store the timestamps a **MongoDB** database is needed. Once the 
database is available, an **Eve** framework can be deployed with a schema to
receive the REST requests to store and retrieve the JSON documents that 
store the timestamps. The **Eve** REST framework is deployed with **Gunicorn**
in order to be able to cater for concurrent requests.

## Usage and examples

The direct way to use this module is to signal for a 'start' or an 
'end' event of either an experiment or a test. 

### Experiment handling
Experiments represent a group of several tests, thus its starting 
and ending times represent the time window while all the tests 
were executed.


##### Signal start
* To create a new experiment timestamping info, signal the start of an experiment by running:
```
python3 src/timestamping/signal_experiment.py start Exp0

```
* and pass the generated data to the mongodb agent that will send it to be stored in the mongodb database:
```
python3 src/mongodb/mongodb_agent.py

```
* Full 'start' command:
```
python3 src/timestamping/signal_experiment.py start Exp0 \
| python3 src/mongodb/mongodb_agent.py

```

##### Signal end

* To manually signal the end of an experiment, run the same pipeline but by signaling for the end with:
```
python3 src/timestamping/signal_experiment.py end Exp0
```
* Full 'end' command:
```
python3 src/timestamping/signal_experiment.py end Exp0 \
| python3 src/mongodb/mongodb_agent.py

```


##### Retrieving info
To get an experiment info, a simple python script is provided.
* To get the raw info as JSON, run:
```
python3 src/timestamping/signal_experiment.py info Exp0
```
```
{"type": "experiment", "info": {"username": "root", "start_time": 1559136727, "end_time": 1559136770, "experiment_id": "Exp0"}}
```
* You can get the same info prettyfied with:
```
python3 src/timestamping/signal_experiment.py info Exp0 \
| python -m json.tool
```
```
{
    "info": {
        "end_time": 1559136770,
        "experiment_id": "Exp0",
        "start_time": 1559136727,
        "username": "root"
    },
    "type": "experiment"
}

```
* You can also extract fields from the JSON using bash tools such as 'jq' (you may need to install it), for example to get the end time:
```
python3 src/timestamping/signal_experiment.py info Exp0 2>/dev/null \
| jq -r '.info.end_time'
```
```
1559136770
```

* You can get all the experiments using:
```
python3 src/timestamping/signal_experiment.py info ALL
```

* To 'delete' an experiment:
```
python3 src/timestamping/signal_experiment.py delete Exp0
```


### Tests handling
Tests represent a single execution of any application of interest. As tests are associated to an experiment, they must be signaled in a similar way as with experiments, with a start or end parameter, but besides the experiment name an additional test_name parameter is needed.

* Full 'start' command:
```
python3 src/timestamping/signal_test.py start Exp0 Test0 \
| python3 src/mongodb/mongodb_agent.py

```

* Full 'end' command:
```
python3 src/timestamping/signal_experiment.py end Exp0 Test0 \
| python3 src/mongodb/mongodb_agent.py

```

* To 'delete' a test:
```
python3 src/timestamping/signal_test.py delete Exp0 Test0
```



##### Retrieving info
To get a test info, a simple python script is provided.
* To get the raw info as JSON, run:
```
python3 src/timestamping/signal_test.py info Exp0 Test0
```
```
{"type": "test", "info": {"username": "root", "start_time": 1559142889, "end_time": 1559143106, "test_name":"Test0", "experiment_id": "Exp0", "test_id": "Exp0_Test0"}}
```
* You can get the same info prettyfied with:
```
python3 src/timestamping/signal_test.py info Exp0 Test0 \
| python -m json.tool
```
```
{
    "info": {
        "end_time": 1559143106,
        "experiment_id": "Exp0",
        "start_time": 1559142889,
        "test_name": "Test0",
        "test_id": "Exp0_Test0",
        "username": "root"
    },
    "type": "test"
}

```
* You can also extract fields from the JSON using bash tools such as 'jq' (you may need to install it), for example to get the end time:
```
python3 src/timestamping/signal_test.py info Exp0 Test0 2>/dev/null \
| jq -r '.info.end_time'
```
```
1559143106
```

## Other features

* This service also allows user separation with an option argument to be passed
to the signal_experiment.py signal_test.py programs. E.g., to signal the start of
experiment 'Exp0' of user 'john', you can use:
```
python3 src/timestamping/signal_test.py start Exp0 --username john \
| python3 src/mongodb/mongodb_agent.py
```

* It is also possible to specify a timestamp to be used for 'start' and 'end' signalign. 
To specify the timestamp of '2018/06/14-12:34:00' for the experiment 'Exp0' start, you can use:
```
python3 src/timestamping/signal_test.py start Exp0 --time '2018/06/14-12:34:00' \
| python3 src/mongodb/mongodb_agent.py
```
