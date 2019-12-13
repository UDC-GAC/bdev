import {changeGraphValues, reDrawGraphByNumber, addGraph} from "./timeseries.js";
import {addFormFromFile} from "../../index.js";
import {getFormFromDiv, getNumFromForm, getTodayTime, getNowTime, setNowTime} from "../forms.js";
import {addReport} from "../reporting/reports.js";

import {formsContainerId} from "../../index.js";

// PUBLIC //
export let monitorings = []
export const divFormsIdBase = "monitorings-form_"

export function addEmptyMetricsForm() {
    "use strict"
    addNewMetricsForm(default_metrics_form)
}

export function addNewMetricsForm(metrics_form) {
    "use strict"
    let newArr = JSON.parse(metrics_form)
    let timeseries = newArr["timeseries"]
    for (let plot of timeseries) {
        addFormFromFile(plot)
    }
}

export function change_datetime_ids() {
    "use strict"
    let datetime
    let newDate = new Date()
    let FiveMinutes = 5 * 60 * 1000
    let ago = newDate.getTime() - FiveMinutes
    let now = newDate.getTime()

    datetime = document.getElementById("datetimepicker0")
    datetime.id = divFormsIdBase + "_" + current_form_number + "_" + datetime.id

    newDate = new Date(ago)
    datetime.children[0].value = getTodayTime(newDate) + "-" + getNowTime(newDate)

    datetime = document.getElementById("datetimepicker1")
    datetime.id = divFormsIdBase + "_" + current_form_number + "_" + datetime.id

    newDate = new Date(now)
    datetime.children[0].value = getTodayTime(newDate) + "-" + getNowTime(newDate)
}

export function addMetricsForm(metrics, yranges) {
    "use strict"
    //Create the form html
    let newdiv = document.createElement("div")
    let divIdName = divFormsIdBase + form_counter
    newdiv.setAttribute("id", divIdName)

    monitorings.push(newdiv)
    newdiv.className += " form"
    //current_form_number = form_counter
    let this_form_number = form_counter
    form_counter = form_counter + 1

    addGraph(metrics)
    addReport(metrics)

    //Add the new metrics form to the container
    let theContainer = document.getElementById(formsContainerId)
    theContainer.appendChild(newdiv)
    $("#" + newdiv.id).load(metrics_form_html_filename, function () {
        initializeForm(this_form_number, metrics, yranges)
    })

    //Return the number of this new metrics form
    return this_form_number
}

export function changeTimeValues(form, start_date, end_date) {
    "use strict"
    let graph_number = getNumFromForm(form)
    let metrics = readFormMetrics(form)
    changeGraphValues(graph_number, metrics, start_date, end_date)
}

export function readFormMetrics(form) {
    "use strict"
    let metricsHtml = form.getElementsByClassName("metric")
    let metrics = []
    for (let i = 0; i < metricsHtml.length; i++) {
        let metric = {}
        let metricHtml = metricsHtml[i]

        metric["aggregator"] = metricHtml.value.split(":")[0]
        metric["metric"] = metricHtml.value.split(":")[1]


        let tagsHtml = metricHtml.parentNode.getElementsByClassName("tag")
        let tags = []
        for (let j = 0; j < tagsHtml.length; j++) {
            tags.push(tagsHtml[j].value)
        }
        metric["tags"] = tags

        metrics.push(metric)
    }
    return metrics
}


export function refreshTimeNow(form) {
    let checkbox = form.elements.autoreload
    if (checkbox.checked) {
        let autoreload_time = form.elements.autoreload_time.value
        setTimeout(refreshTimeNow, autoreload_time * 1000, form)
        setNowTime(form, 1)
        drawTimeseries(form)
        handleReport(form)
    } else {
        setNowTime(form)
    }
}

export function drawTimeseries(form) {
    "use strict"
    let start_date = form.elements.datetime0.value
    let end_date = form.elements.datetime1.value
    let graph_number = getNumFromForm(form)

    let metrics = readFormMetrics(form)

    changeGraphValues(graph_number, metrics, start_date, end_date)
    reDrawGraphByNumber(graph_number)
}

export function addMetric(form, metric) {
    let metricsDiv = form.getElementsByClassName("monitorings-div")[0]

    if (metric === undefined) {
        metric = default_metric
    }

    let divList = get_list_from_element(metricsDiv)
    let tags = metric["tags"]
    //~ let metric_label = metric["metric"]
    //~ let metric_aggregator = metric["aggregator"]
    let element = $("<div class=\"row metric-row\" ondragover=\"cancelDragOver()\">").load(metric_html_filename, function () {
        this.firstChild.value = metric["aggregator"] + ":" + metric["metric"]
        for (let i = 0; i < tags.length; i++) {
            addTag(element[0], tags[i])
        }
    })
    element.appendTo(divList)
}

export function addTag(metric, tag) {
    let tagsDiv = metric.getElementsByClassName("tags-div")[0]

    if (tag === null) {
        tag = defaultTag
    }

    let divList = get_list_from_element(tagsDiv)
    let element = $("<div class=\"row tag-row\" ondragover=\"cancelDragOver()\">").load(tag_html_filename, function () {
        this.firstChild.value = tag
    })
    element.appendTo(divList)
}
export function removeThisMetricOrTag(button) {
    let input = button.parentNode.children[0] //input of this button
    let aElements = button.parentNode.parentNode.getElementsByClassName("row")
    let aElementsLength = aElements.length
    for (let i = 0; i < aElementsLength; i++) {
        if (aElements[i] === button.parentNode) {
            button.parentNode.parentNode.removeChild(aElements[i])
            break
        }
    }
}


export const node0_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node0\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node0\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node0\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node0\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}}]}"
export const node1_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node1\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node1\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node1\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node1\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}},{\"metrics\":[{\"metric\": \"proc.disk.reads.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node1\"]},{\"metric\": \"proc.disk.writes.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node1\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 120}},{\"metrics\":[{\"metric\": \"proc.net.tcp.in.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node1\"]},{\"metric\": \"proc.net.tcp.out.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node1\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 2500}}]}"
export const node2_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node2\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node2\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node2\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node2\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}},{\"metrics\":[{\"metric\": \"proc.disk.reads.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node2\"]},{\"metric\": \"proc.disk.writes.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node2\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 120}},{\"metrics\":[{\"metric\": \"proc.net.tcp.in.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node2\"]},{\"metric\": \"proc.net.tcp.out.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node2\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 2500}}]}"
export const node3_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node3\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node3\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node3\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node3\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}},{\"metrics\":[{\"metric\": \"proc.disk.reads.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node3\"]},{\"metric\": \"proc.disk.writes.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node3\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 120}},{\"metrics\":[{\"metric\": \"proc.net.tcp.in.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node3\"]},{\"metric\": \"proc.net.tcp.out.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"host=node3\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 2500}}]}"
export const nodeManagers_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NodeManager\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NodeManager\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NodeManager\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NodeManager\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}},{\"metrics\":[{\"metric\": \"proc.disk.reads.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NodeManager\"]},{\"metric\": \"proc.disk.writes.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NodeManager\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 120}},{\"metrics\":[{\"metric\": \"proc.net.tcp.in.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NodeManager\"]},{\"metric\": \"proc.net.tcp.out.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NodeManager\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 2500}}]}"
export const dataNodes_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=DataNode\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=DataNode\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=DataNode\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=DataNode\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}},{\"metrics\":[{\"metric\": \"proc.disk.reads.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=DataNode\"]},{\"metric\": \"proc.disk.writes.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=DataNode\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 120}},{\"metrics\":[{\"metric\": \"proc.net.tcp.in.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=DataNode\"]},{\"metric\": \"proc.net.tcp.out.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=DataNode\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 2500}}]}"
export const YarnChilds_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=YarnChild\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=YarnChild\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=YarnChild\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=YarnChild\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}},{\"metrics\":[{\"metric\": \"proc.disk.reads.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=YarnChild\"]},{\"metric\": \"proc.disk.writes.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=YarnChild\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 120}},{\"metrics\":[{\"metric\": \"proc.net.tcp.in.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=YarnChild\"]},{\"metric\": \"proc.net.tcp.out.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=YarnChild\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 2500}}]}"
export const SparkExecutors_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=CoarseGrainedExecutorBackend\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=CoarseGrainedExecutorBackend\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=CoarseGrainedExecutorBackend\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=CoarseGrainedExecutorBackend\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}},{\"metrics\":[{\"metric\": \"proc.disk.reads.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=CoarseGrainedExecutorBackend\"]},{\"metric\": \"proc.disk.writes.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=CoarseGrainedExecutorBackend\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 120}},{\"metrics\":[{\"metric\": \"proc.net.tcp.in.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=CoarseGrainedExecutorBackend\"]},{\"metric\": \"proc.net.tcp.out.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=CoarseGrainedExecutorBackend\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 2500}}]}"
export const NameNode_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NameNode\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NameNode\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NameNode\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NameNode\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}},{\"metrics\":[{\"metric\": \"proc.disk.reads.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NameNode\"]},{\"metric\": \"proc.disk.writes.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NameNode\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 120}},{\"metrics\":[{\"metric\": \"proc.net.tcp.in.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NameNode\"]},{\"metric\": \"proc.net.tcp.out.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=NameNode\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 2500}}]}"
export const ResourceManager_form = "{\"timeseries\":[{\"metrics\":[{\"metric\": \"proc.cpu.user\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=ResourceManager\"]},{\"metric\": \"proc.cpu.kernel\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=ResourceManager\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 700}},{\"metrics\":[{\"metric\": \"proc.mem.resident\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=ResourceManager\"]},{\"metric\": \"proc.mem.swap\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=ResourceManager\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 25000}},{\"metrics\":[{\"metric\": \"proc.disk.reads.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=ResourceManager\"]},{\"metric\": \"proc.disk.writes.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=ResourceManager\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 120}},{\"metrics\":[{\"metric\": \"proc.net.tcp.in.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=ResourceManager\"]},{\"metric\": \"proc.net.tcp.out.mb\",\"aggregator\" : \"zimsum\",\"tags\" : [\"command=ResourceManager\"]}],\"yranges\":{\"ymin\": 0,\"ymax\": 2500}}]}"


// FIXME
// This is needed to allow the main page functions and variables to be exposed
window.node0_form = node0_form
window.node1_form = node1_form
window.node2_form = node2_form
window.node3_form = node3_form
window.nodeManagers_form = nodeManagers_form
window.dataNodes_form = dataNodes_form
window.YarnChilds_form = YarnChilds_form
window.SparkExecutors_form = SparkExecutors_form
window.NameNode_form = NameNode_form
window.ResourceManager_form = ResourceManager_form


window.addNewMetricsForm = addNewMetricsForm
window.change_datetime_ids = change_datetime_ids
window.addEmptyMetricsForm = addEmptyMetricsForm
window.drawTimeseries = drawTimeseries
window.addMetric = addMetric
window.addTag = addTag
window.removeThisMetricOrTag = removeThisMetricOrTag

// PRIVATE //

let form_counter = 0
let current_form_number = 0
const tag_html_filename = "html/tag.html"
const metric_html_filename = "html/metric.html"
const metrics_form_html_filename = "html/monitorings_form.html"
const default_metric = {metric: "proc.cpu.user", aggregator: "zimsum", tags: ["host=node0", "command=YarnChild"]}
const default_metrics_form = "{\"timeseries\":[{\"metrics\":[{\"metric\":\"proc.cpu.user\",\"aggregator\":\"zimsum\",\"tags\":[\"host=node1\"]}],\"yranges\":{\"ymin\":0,\"ymax\":800}}]}"
const defaultTag = "host=node0"

function get_list_from_element(element) {
    for (let i = 0; i < element.children.length; i++) {
        if (element.children[i].tagName === "UL") {
            return element.children[i]
        }
    }
}


let initializeForm = function (form_number, metrics, yranges) {
    "use strict"
    let form = getFormFromDiv(document.getElementById(divFormsIdBase + form_number))
    for (let metric of metrics) {
        addMetric(form, metric)
    }
    form.elements.min_y.value = yranges.ymin
    form.elements.max_y.value = yranges.ymax
    form.elements.scaleY.checked = true


    let start_date = form.elements.datetime0.value
    let end_date = form.elements.datetime1.value
    let graph_number = getNumFromForm(form)

    changeGraphValues(graph_number, metrics, start_date, end_date)
}
