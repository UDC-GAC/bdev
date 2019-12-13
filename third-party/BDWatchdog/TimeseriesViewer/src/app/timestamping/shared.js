import {createCORSRequest, defaultExperimentsInfoURL} from "../../index.js";

export function getMongoURLfromUI() {
    "use strict";
    let form = document.getElementById("experiment_picker");
    let url = form.elements.endpoint.value;
    let endpoint;
    if (url === null)
        endpoint = defaultExperimentsInfoURL;
    else
        endpoint = url;
    return endpoint
}


export function sendCORSrequest(HTTPmethod, endpoint, headers, expected_status_code, success_function, error_message){
    "use strict";


    let xhr = createCORSRequest(HTTPmethod, endpoint);
    if (!xhr) {
        throw new Error("CORS not supported")
    }
    for (let h in headers){
        xhr.setRequestHeader(headers[h].header, headers[h].value);
    }

    let response;
    xhr.onload = function () {
        if (xhr.status === expected_status_code) {
            if (xhr.responseText !== ""){
                response = JSON.parse(xhr.responseText);
                success_function(response)
            }
        } else {
            alert(error_message)
        }
    };

    xhr.onerror = function () {
        alert("Error with CORS request")
    };

    xhr.send()

}