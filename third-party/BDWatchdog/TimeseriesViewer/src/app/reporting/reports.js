import {
    createJson,
    getGraphData,
    parseResponseMetricsData,
    defaultEndDate,
    defaultStartDate
} from "../monitoring/timeseries.js";
import {readFormMetrics} from "../monitoring/monitorings.js";
import {getNumFromForm} from "../forms.js";
import {reportsContainerId} from "../../index.js";
import {drawGraph} from "../monitoring/timeseries.js";

const reportsIdBase = "report_";
let report_counter = 0;
let reports_dict = {};

//####### ADD REPORT #######
function getNumFromReportID(reportID) {
    "use strict"
    return reportID.split("_")[1]
}

function getReportDictByNum(report_number) {
    "use strict"
    let reportID = reportsIdBase + report_number
    return reports_dict[reportID]
}

export function increase_report_counter(){
    report_counter = report_counter + 1
}

export function decrease_report_counter(){
    report_counter = report_counter - 1
}

export function addReport(metrics) {
    "use strict"
    //Generate the ID string of the graph
    let reportID = reportsIdBase + report_counter

    //Store all the graph data and metadata
    reports_dict[reportID] = {}
    let report_info = reports_dict[reportID]
    report_info.start_date = defaultStartDate
    report_info.end_date = defaultEndDate
    report_info.metrics = metrics
    report_info.data = {}
    report_info.data.points = []
    report_info.data.labels = []

    //Increment the counter of graphs displayed
    increase_report_counter()
}

function tabulate(data, columns, report_number) {
    let table = d3.select("#" + reportsIdBase + report_number)
            .append("table")
            .attr("style", "color: black; margin-left: 20px; border-collapse: collapse;"),
        thead = table.append("thead"),
        tbody = table.append("tbody")

    // append the header row
    thead.append("tr")
        .selectAll("th")
        .data(columns)
        .enter()
        .append("th")
        .attr("style", "padding: 10px; border: 1px solid black;")
        .text(function (column) {
            return column
        })

    // create a row for each object in the data
    let rows = tbody.selectAll("tr")
        .data(data)
        .enter()
        .append("tr")

    // create a cell in each row for each column
    let cells = rows.selectAll("td")
        .data(function (row) {
            return columns.map(function (column) {
                return {column: column, value: row[column]}
            })
        })
        .enter()
        .append("td")
        .attr("style", "font-family: Courier; padding: 10px; border: 1px solid black;")
        .html(function (d) {
            return d.value
        })

    return table
}

function createReport(parsedData, reportID, dataHasChanged) {
    "use strict"
    let report_number = getNumFromReportID(reportID)
    let report_info = getReportDictByNum(report_number)

    let reportsContainer = document.getElementById(reportsContainerId)


    let aggregations
    let labels_array
    let elapsed_time = parsedData.real_end - parsedData.real_start
    let allSUM = {}
    let allAVG = {}
    if (dataHasChanged) {
        let allMetricsValues = parsedData.points
        labels_array = parsedData.labels


        aggregations = []
        for (let i = 0; i < allMetricsValues.length; i++) {
            let metrics = allMetricsValues[i]

            let aggregate = metrics[0].value // Start with the first value

            // Perform the integration through steps
            for (let j = 1; j < metrics.length; j++) {
                let diff_time = (metrics[j].time - metrics[j - 1].time)
                aggregate = aggregate + (metrics[j].value * diff_time)
            }


            let average = aggregate / elapsed_time

            aggregations.push({aggregation: "SUM", value: aggregate, label: labels_array[i]})
            aggregations.push({aggregation: "AVG", value: average, label: labels_array[i]})
        }


        for (let agg of aggregations) {
            if (agg.aggregation === "SUM") {
                let label = agg.label.split(";")[0]
                if (label in allSUM) {
                    allSUM[label] = allSUM[label] + agg.value
                } else {
                    allSUM[label] = agg.value
                }
            } else if (agg.aggregation === "AVG") {
                let label = agg.label.split(";")[0]
                if (label in allAVG) {
                    allAVG[label] = allAVG[label] + agg.value
                } else {
                    allAVG[label] = agg.value
                }

            }
        }

        report_info.aggregations = aggregations
        report_info.real_start = parsedData.real_start
        report_info.real_end = parsedData.real_end

    } else {
        aggregations = report_info.aggregations
    }

    report_info.is_energy = (labels_array[0].startsWith("sys.cpu.energy") ||
        labels_array[0].startsWith("structure.energy.current"))

    let element = document.getElementById(reportsIdBase + report_number)
    if (element !== null) {
        element.parentNode.removeChild(element)
    }

    let textBox = document.createElement("div")
    textBox.setAttribute("class", "report")
    textBox.setAttribute("id", reportsIdBase + report_number)
    //textBox.setAttribute("style","width:500px")

    // Report the total run tim
    appendReportPill(textBox, "TOTAL RUN TIME IS : " + elapsed_time + " seconds")

    let headers = []
    let results = []
    headers.push("aggregation")
    for (let agg of aggregations) {
        let label = agg.label.split(";")[0]
        if (!headers.includes(label)) {
            headers.push(label)
        }
    }
    headers.push("tags")

    function addRow(info, row) {
        row["aggregation"] = info.aggregation
        row["tags"] = info.label.split(";")[1]
        let label = info.label.split(";")[0]
        row[label] = printInfoOfResource(info.aggregation, label, info.value)
        return row
    }

    let collapsedRows = {}
    for (let agg of aggregations) {
        let tag = agg.label.split(";")[1]
        let aggregation = agg.aggregation
        if (collapsedRows[tag] === undefined) {
            collapsedRows[tag] = {}
        }
        if (collapsedRows[tag][aggregation] === undefined) {
            collapsedRows[tag][aggregation] = []
        }
        collapsedRows[tag][aggregation].push(agg)
    }


    for (const [tag, value] of Object.entries(collapsedRows)) {
        for (const [agg, rows] of Object.entries(value)) {
            let row = {};
            for (let collapsedRow of rows) {
                row = addRow(collapsedRow, row)
            }
            results.push(row)
        }
    }

    let rowSUM = {}
    rowSUM["aggregation"] = "SUM SUM"
    for (let sum in allSUM) {
        if (allSUM.hasOwnProperty(sum)) {
            rowSUM[sum] = printInfoOfResource("SUM", sum, allSUM[sum])
        }
    }
    rowSUM["tags"] = "ALL"
    results.push(rowSUM)

    let rowAVG = {}
    rowAVG["aggregation"] = "SUM AVG"
    for (let avg in allAVG) {
        if (allAVG.hasOwnProperty(avg)) {
            rowAVG[avg] = printInfoOfResource("AVG", avg, allAVG[avg])
        }
    }
    rowAVG["tags"] = "ALL"
    results.push(rowAVG)


    //Report energy or resources
    if (report_info.is_energy === true) {
        printEnergyReport(textBox, allSUM[Object.keys(allSUM)[0]])
    }
    reportsContainer.appendChild(textBox)

    tabulate(results, headers, report_number)
}

function printEnergyReport(textBox, totalEnergy) {
    "use strict"
    let energy_price_euros_per_KWh = 0.16
    let watts_second = totalEnergy.toFixed(2)
    let kwatts_hour = (totalEnergy / 3600000).toFixed(2)
    let energy_message =
        "TOTAL ENERGY CONSUMPTION IS: " + watts_second +
        " Watts-second, or " + kwatts_hour + "KWh, " +
        " WITH COST : " + (kwatts_hour * energy_price_euros_per_KWh).toFixed(2) + "€"

    appendReportPill(textBox, energy_message)
}


function printInfoOfResource(aggregator, label, value) {
    "use strict"
    let string = ""
    if (label.startsWith("sys.cpu.energy") || label.startsWith("structure.energy")) {
        string = value.toFixed(2) + " Watt-seconds"
    } else if (label.startsWith("proc.cpu") || label.startsWith("sys.cpu") || label.startsWith("structure.cpu") || label.startsWith("limit.cpu")) {
        string = (value / 100).toFixed(2) + " vcore-seconds"
    } else if (label.startsWith("proc.mem") || label.startsWith("sys.mem") || label.startsWith("structure.mem") || label.startsWith("limit.mem")) {
        string = value.toFixed(2) + " MB-seconds"
    } else if (label.startsWith("proc.disk") || label.startsWith("sys.disk") || label.startsWith("structure.disk") || label.startsWith("limit.disk")) {
        string = (value / 100).toFixed(2) + " Mbits"
    } else if (label.startsWith("proc.net") || label.startsWith("sys.net") || label.startsWith("structure.net") || label.startsWith("limit.net")) {
        string = value.toFixed(2) + " Mbits"
    } else {
        string = value.toFixed(2)
    }
    if (aggregator === "AVG") {
        string += "/s"
    }
    return string
}


function appendReportPill(parent, message) {
    "use strict"
    let label = document.createElement("p")
    label.setAttribute("class", "report-pill")
    label.innerText = message
    parent.appendChild(label)
}


function changeReportValues(report_number, metrics, start_date, end_date) {
    "use strict"
    let report_info = getReportDictByNum(report_number)
    report_info.start_date = start_date
    report_info.end_date = end_date
    report_info.metrics = metrics
}


function getReportID(report_num) {
    "use strict"
    return reportsIdBase + report_num
}

export function removeReportByNumber(report_number) {
    "use strict"
    let reportID = getReportID(report_number)
    delete reports_dict[reportID]
    let element = document.getElementById(reportID)
    if (element !== null) {
        element.parentNode.removeChild(element)
    }
}

function reWriteReportByNumber(report_number) {
    "use strict"
    let report_info = getReportDictByNum(report_number)
    let start_date = report_info.start_date
    let end_date = report_info.end_date
    let metrics = report_info.metrics
    let reportID = reportsIdBase + report_number

    //Define the callback function to draw data after it has been retrieved
    let callback = function (response, graphID) {
        report_info.data = parseResponseMetricsData(response, graphID)
        createReport(report_info.data, reportID, true)
    }

    let callback_error = function (response, graphID) {
        graph_info["data"] = {}
        graph_info["data"]["points"] = []
        drawGraph(graph_info["data"], graphID, true)
    }

    getGraphData(createJson(start_date, end_date, metrics, report_number, "1s-avg"), reportID, callback, callback_error)
}

export function handleReport(form) {
    "use strict"
    let start_date = form.elements.datetime0.value
    let end_date = form.elements.datetime1.value
    let report_number = getNumFromForm(form)

    let metrics = readFormMetrics(form)

    changeReportValues(report_number, metrics, start_date, end_date)
    reWriteReportByNumber(report_number)
}

window.handleReport = handleReport