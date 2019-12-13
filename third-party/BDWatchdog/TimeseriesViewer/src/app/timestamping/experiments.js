import {timeConverter} from "../../index.js";
import {getMongoURLfromUI, sendCORSrequest} from "./shared.js";


export function getExperimentsFromMongo(username) {
    "use strict";
    let endpoint = getMongoURLfromUI();
    let headers = [ {"header":"Accept", "value":"application/json"} ];
    let mongo_REST_endpoint = endpoint + "/experiments?where={%22username%22:%22" + username + "%22}";

    //sendCORSrequest("GET", mongo_REST_endpoint, headers, 200, function (response){
    //    populateExperimentsDropdown(response)
    //}, "Error getting experiments");

    getExperimentsFromMongoPaginated(mongo_REST_endpoint, true)

}

function getExperimentsFromMongoPaginated(mongo_REST_endpoint, remove_previous){
    let headers = [ {"header":"Accept", "value":"application/json"} ];
    sendCORSrequest("GET", mongo_REST_endpoint, headers, 200, function (response){
        populateExperimentsDropdown(response, remove_previous);
        if (response._meta["page"] * response["_meta"]["max_results"] < response["_meta"]["total"]){
            getExperimentsFromMongoPaginated(getMongoURLfromUI() + "/" + response["_links"]["next"]["href"], false);
        }
    }, "Error getting experiments");
}

export function getExperimentTimes() {
    "use strict";
    let experiments_form = document.getElementById("experiment_picker");
    let experiment_label = experiments_form.elements.experiment;
    let experiment_id = experiment_label.experiment_id;

    let endpoint = getMongoURLfromUI();
    let headers = [ {"header":"Accept", "value":"application/json"} ];
    let mongo_REST_endpoint = endpoint + "/experiments/" + experiment_id;
    sendCORSrequest("GET", mongo_REST_endpoint, headers,  200, function (response){
        propagateExperimentTimes(response)
    }, "Error getting experiment times");
}


export function deleteExperiment() {
    "use strict";
    let experiments_form = document.getElementById("experiment_picker");
    let experiment_label = experiments_form.elements.experiment;
    let experiment_id = experiment_label.experiment_id;
    let experiment_etag = experiment_label.etag;

    let endpoint = getMongoURLfromUI();
    let headers = [ {"header":"Accept", "value":"application/json"}, {"header":"If-Match", "value":experiment_etag} ];
    let mongo_REST_endpoint = endpoint + "/experiments/" + experiment_id;


    sendCORSrequest("DELETE", mongo_REST_endpoint, headers,  204, function (response){}, "Error deleting experiment information");
}


function experiment_label_on_click() {
    "use strict";
    let experiments_form = document.getElementById("experiment_picker");
    let experiment_label = experiments_form.elements.experiment;
    experiment_label.value = this.innerText;
    experiment_label.experiment_id = this.experiment_id;
    experiment_label.etag = this.etag;
}


function propagateExperimentTimes(experiment) {
    "use strict";
    let times = document.getElementById("times_form");
    times.elements.global_start_time.value = timeConverter(experiment.start_time);
    times.elements.global_end_time.value = timeConverter(experiment.end_time);

}

function populateExperimentsDropdown(experiments, remove_previous) {
    "use strict";
    let list = document.getElementById("exps_timepicker_list");

    if(remove_previous) {
        while (list.firstChild) {
            list.removeChild(list.firstChild);
        }
    }

    experiments._items.sort(function(a, b){
        if(a.start_time < b.start_time) return -1;
        if(a.start_time > b.start_time) return 1;
        return 0;
    });


    for (let experiment of experiments._items) {
        let child = document.createElement("li");
        child.innerHTML = experiment.experiment_id;
        child.experiment_id = experiment._id;
        child.etag = experiment._etag;
        child.onclick = experiment_label_on_click;
        list.append(child);
    }
}
