import {removeGraphByNumber} from "./graphs.js";

import {monitorings} from "./monitoring/monitorings.js";
import {profilings} from "./profiling/profilings.js";
import {removeReportByNumber} from "./reporting/reports.js";


export function getNumFromForm(form) {
    "use strict";
    return form.parentNode.id.split("_")[1]
}

// For todays date;
export function getTodayTime(date){
    "use strict";
    return date.getFullYear() + "/" + (((date.getMonth() + 1) < 10) ? "0" : "") +
            (date.getMonth() + 1) + "/" + ((date.getDate() < 10) ? "0" : "") + date.getDate()

}

export function getNowTime(date){
    "use strict";
    return ((date.getHours() < 10) ? "0" : "") + date.getHours() + ":" + ((date.getMinutes() <
        10) ? "0" : "") + date.getMinutes() + ":" + ((date.getSeconds() < 10) ? "0" :
        "") + date.getSeconds()
}


export function setNowTime(form, timepicker) {
    let newDate = new Date()
    let datetime = getTodayTime(newDate) + "-" + getNowTime(newDate)

    if (timepicker === 0) {
        form.elements.datetime0.value = datetime
    }else if (timepicker === 1) {
        form.elements.datetime1.value = datetime
    }
}


export function getFormFromDiv(div) {
    for (let child of div.children) {
        if (child.nodeName === "FORM") {
            return child
        }
    }
}

export function changeTimeInputs(form, start_time, end_time) {
    form.elements.datetime0.value = start_time
    form.elements.datetime1.value = end_time
}

function removeFormById(formID) {
    let element = document.getElementById(formID)
    element.parentNode.removeChild(element)
    let index;
    let graph_number;

    for (let form of monitorings){
        if (form.id === formID) {
            index = monitorings.indexOf(form)
            //Remove from metrics list
            monitorings.splice(index, 1)
            graph_number = getNumFromForm(form.firstChild)
            //Remove from graphs container and dictionary
            removeGraphByNumber("graph", graph_number)
            removeReportByNumber(graph_number)
        }

    }
    for (let form of profilings){
        if (form.id === formID) {
            index = profilings.indexOf(form)
            profilings.splice(index, 1)
            graph_number = getNumFromForm(form.firstChild)
            removeGraphByNumber("flamegraph", graph_number)
        }
    }


}

export function removeForm(form) {
    removeFormById(form.id)
}

window.removeForm = removeForm
window.setNowTime = setNowTime