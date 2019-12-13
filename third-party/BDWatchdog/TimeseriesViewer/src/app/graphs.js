import {getFlameGraphDictByNum} from "./profiling/flamegraphs.js";
import {getGraphDictByNum, drawGraph} from "./monitoring/timeseries.js";

import {graphsContainerId} from "../index.js";
import {graphs_dict} from "./monitoring/timeseries.js";


const graphsIdBase = "graph_";
export function getGraphNumFromID(ID) {
    "use strict";
    return ID.split("_")[1];
}

export function getGraphID(graph_num) {
    "use strict";
    return graphsIdBase + graph_num;
}

export function removeGraphByNumber(graph_type, graph_number) {
    "use strict";
    let graphsContainer = document.getElementById(graphsContainerId);
    let graphsContainers = graphsContainer.children
    let graphID = getGraphID(graph_number)

    for (let graph of graphsContainers) {
        if (graph.id.split("_")[2] === graph_number && graph_type === graph.id.split("_")[1]) {
            graphsContainer.removeChild(graph)
            delete graphs_dict[graphID]
            break
        }
    }
}

export function triggerResize(graphID, graphX, graphY) {
    "use strict";
    let graph_number = getGraphNumFromID(graphID)
    let resizableContainer
    if (graphID.startsWith("flamegraph_")) {
        let flamegraph_info = getFlameGraphDictByNum(graph_number)
        changeFlamegraphSize(graph_number, graphX, graphY)
        drawFlameGraph(flamegraph_info["data"], graphID, false)
        resizableContainer = document.getElementById("containerResizableFlamegraph_" + graphID)
    }else if (graphID.startsWith(graphsIdBase)) {
        let graph_info = getGraphDictByNum(graph_number)
        changeImageSize(graph_number, graphX, graphY)
        drawGraph(graph_info["data"], graphID, false)
        resizableContainer = document.getElementById("containerResizable_" + graphID)
    }
    resizableContainer.style = "overflow:auto;"
}

function changeImageSize(graph_number, graphX, graphY) {
    let graph_info = getGraphDictByNum(graph_number)
    graph_info["sizeX"] = graphX
    graph_info["sizeY"] = graphY
}

// target elements with the "draggable" class
interact(".draggable")
    .draggable({
        // enable inertial throwing
        inertia: true,
        // keep the element within the area of it's parent
        restrict: {
            restriction: "parent",
            endOnly: true,
            elementRect: {top: 0, left: 0, bottom: 1, right: 1}
        },
        // enable autoScroll
        autoScroll: true,

        // call this function on every dragmove event
        onmove: dragMoveListener,
        // call this function on every dragend event
        onend: function (event) {
            let textEl = event.target.querySelector("p")

            textEl && (textEl.textContent =
                "moved a distance of "
                + (Math.sqrt(event.dx * event.dx +
                event.dy * event.dy) | 0) + "px")
        }
    })

function dragMoveListener(event) {
    let target = event.target,
        // keep the dragged position in the data-x/data-y attributes
        x = (parseFloat(target.getAttribute("data-x")) || 0) + event.dx,
        y = (parseFloat(target.getAttribute("data-y")) || 0) + event.dy

    // translate the element
    target.style.webkitTransform =
        target.style.transform =
            "translate(" + x + "px, " + y + "px)"

    // update the posiion attributes
    target.setAttribute("data-x", x)
    target.setAttribute("data-y", y)
}

// this is used later in the resizing and gesture demos
window.dragMoveListener = dragMoveListener

//Add resizing behaviour
interact(".resize-drag")
    .draggable({
        onmove: window.dragMoveListener
    })
    .resizable({
        preserveAspectRatio: false,
        edges: {left: false, right: true, bottom: true, top: false}
    })
    .on("resizemove", function (event) {
        let target = event.target,
            x = (parseFloat(target.getAttribute("data-x")) || 0),
            y = (parseFloat(target.getAttribute("data-y")) || 0)

        // update the element"s style
        target.style.width = event.rect.width + "px"
        target.style.height = event.rect.height + "px"

        // translate when resizing from top or left edges
        x += event.deltaRect.left
        y += event.deltaRect.top

        target.style.webkitTransform = target.style.transform =
            "translate(" + x + "px," + y + "px)"

        target.setAttribute("data-x", x)
        target.setAttribute("data-y", y)
        triggerResize(target.firstChild.id, event.rect.width, event.rect.height)
    })


function download(filename, text) {
    "use strict";
    let element = document.createElement("a")
    element.setAttribute("href", "data:text/plain;charset=utf-8," + encodeURIComponent(text))
    element.setAttribute("download", filename)

    element.style.display = "none"
    document.body.appendChild(element)

    element.click()

    document.body.removeChild(element)
}

// export function downloadSVG(graphID) {
//     let svg_style = readTextFile("css/graphs.css")
//     let all_style = svg_style.replace(/\r?\n|\r/g, "").split("}")
//     all_style.forEach(function (el) {
//         if (el.trim() !== "") {
//             let full_rule_string = el.split("{")
//             let selector = full_rule_string[0].trim()
//             let all_rule = full_rule_string[1].split(";")
//             all_rule.forEach(function (elem) {
//                 if (elem.trim() !== "") {
//                     let attr_value = elem.split(":")
//                     d3.selectAll(selector).style(attr_value[0].trim() + "", attr_value[1].trim() + "")
//                 }
//             })
//         }
//     })
//     $("#" + graphsContainerId).after("<canvas id=\"sm_canvas\" style=\"display=none;\"></canvas>")
//     let canvas = document.getElementById("sm_canvas")
//     canvg(canvas, $("<div>").append($("#" + graphID).clone()).html())
//     let imgData = canvas.toDataURL("image/png", 1)
//
//     let element
//     element = document.createElement("a")
//     element.setAttribute("href", imgData)
//     element.setAttribute("download", "plot.png")
//     element.style.display = "none"
//     document.body.appendChild(element)
//     element.click()
//     document.body.removeChild(element)
//
//     element = document.getElementById("sm_canvas")
//     element.parentNode.removeChild(element)
// }

function readTextFile(file) {
    let rawFile = new XMLHttpRequest()
    let allText = ""
    rawFile.open("GET", file, false)
    rawFile.onreadystatechange = function () {
        if (rawFile.readyState === 4) {
            if (rawFile.status === 200 || rawFile.status === 0) {
                allText = rawFile.responseText
            }
        }
    }
    rawFile.send(null)
    return allText
}
