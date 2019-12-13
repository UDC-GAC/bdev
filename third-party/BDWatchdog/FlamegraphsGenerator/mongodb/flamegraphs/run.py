from flask import Flask
from flask_cors import CORS, cross_origin
from flask import request
from pymongo import MongoClient
from flask import jsonify
from flask import abort
import json 

client = MongoClient()

app = Flask(__name__)
CORS(app)
db = client.profiling

def serializable_object(node):
    "Recurse into tree to build a serializable object"
    obj = {"n": node["n"], "c": node["c"], "a": []}
    for child in node["a"]:
        obj["a"].append(serializable_object(node["a"][child]))
    return obj


@app.route("/stacks/", methods=['GET'])
def get_stacks():
    start_time_set = False
    end_time_set = False
    
    try:
        try:
            start_time = int(request.form['start_time'])
            start_time_set = True
        except KeyError:
            start_time = int(request.args.get('start_time'))
            start_time_set = True
    except Exception:
        start_time_set = False

    try:
        try:
            end_time = int(request.form['end_time'])
            end_time_set = True
        except KeyError:
            end_time = int(request.args.get('end_time'))
            end_time_set = True
    except Exception:
        end_time_set = False


    try:
        try:
            hostname = request.form['hostname']
        except KeyError:
            hostname = request.args.get('hostname')
    except Exception:
        hostname = "ALL"

    if  not (start_time_set and end_time_set):
        return abort(400)

    if hostname == "ALL":
        results = db.cpu.find({ 
            "$and" : [ 
                    {"timestamp" : { "$gte" : start_time}}, 
                    {"timestamp" : { "$lte" : end_time}},
                ]
        })
    else:
        results = db.cpu.find({ 
            "$and" : [ 
                    {"timestamp" : { "$gte" : start_time}}, 
                    {"timestamp" : { "$lte" : end_time}},
                    {"hostname" : hostname}
                ]
        })
    
    stacks = dict()
    for doc in results:
        try:
            stacks[doc["stack"]] += doc["value"]
        except KeyError:
            stacks[doc["stack"]] = doc["value"]
    return jsonify(stacks)

@app.route("/flamegraph/", methods=['GET'])
def get_flamegraph():
    start_time_set = False
    end_time_set = False
    
    try:
        try:
            start_time = int(request.form['start_time'])
            start_time_set = True
        except KeyError:
            start_time = int(request.args.get('start_time'))
            start_time_set = True
    except Exception:
        start_time_set = False

    try:
        try:
            end_time = int(request.form['end_time'])
            end_time_set = True
        except KeyError:
            end_time = int(request.args.get('end_time'))
            end_time_set = True
    except Exception:
        end_time_set = False


    try:
        try:
            hostname = request.form['hostname']
        except KeyError:
            hostname = request.args.get('hostname')
    except Exception:
        hostname = "ALL"

    if  not (start_time_set and end_time_set):
        return abort(400)

    if hostname == "ALL":
        results = db.cpu.find({ 
            "$and" : [ 
                    {"timestamp" : { "$gte" : start_time}}, 
                    {"timestamp" : { "$lte" : end_time}},
                ]
        })
    else:
        results = db.cpu.find({ 
            "$and" : [ 
                    {"timestamp" : { "$gte" : start_time}}, 
                    {"timestamp" : { "$lte" : end_time}},
                    {"hostname" : hostname}
                ]
        })
    
    stacks = dict()
    for doc in results:
        try:
            stacks[doc["stack"]] += doc["value"]
        except KeyError:
            stacks[doc["stack"]] = doc["value"]


    out_dict = {"n":"ALL", "c":0, "a" : {}}

    for key in stacks:
        parts = key.split(";")
        d = out_dict["a"]
        for part in parts:
            try:
                a = d[part]["n"]
            except KeyError:
                d[part] = dict()
                d[part]["n"] = part
                d[part]["a"] = dict()
                d[part]["c"] = {"RUNNABLE":0} #0
                
            
            if part == parts[len(parts)-1]:
                d[part]["c"] = {"RUNNABLE":stacks[key]}
            else:
                d = d[part]["a"]

    jsonTree = serializable_object(out_dict)

    return(json.dumps({"profile":jsonTree}))
    
    #return jsonify(stacks)

if __name__ == "__main__":
    app.run()

