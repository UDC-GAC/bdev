export const flameGraphsIdBase = 'flamegraph_';
var flameGraph_counter = 0;
var flamegraphs_dict = {};

var defaultFlamegraphsURL = "http://mongodb:8000"
var defaultFlamegraphsStartTime = "1490780820"
var defaultFlamegraphsEndTime = "1490788330"
var defaultFlamegraphsHostname = "hadoop4"

var convert, runnableVals;

convert = function(rawData, valueFunc) {
	var child, j, len, node, ref, subTree;
	node = {
	  name: rawData.n,
	  value: valueFunc(rawData),
	  children: []
	};
	if (!rawData.a) {
	  return node;
	}
	ref = rawData.a;
	for (j = 0, len = ref.length; j < len; j++) {
	  child = ref[j];
	  subTree = convert(child, valueFunc);
	  if (subTree) {
		node.children.push(subTree);
	  }
	}
	return node;
};

var allStates = function(node) {
  var j, len, ref, state, value;
  value = 0;
  ref = ['RUNNABLE', 'BLOCKED', 'TIMED_WAITING', 'WAITING'];
  for (j = 0, len = ref.length; j < len; j++) {
	state = ref[j];
	if (!isNaN(node.c[state])) {
	  value += node.c[state];
	}
  }
  return value;
};


runnableVals = [];

function createFlamegraphJson(start_time, end_time, hostname){
		var final_dict = {}		
		final_dict["start_time"] = start_time
		final_dict["end_time"] = end_time
		
		if (hostname == "" || hostname === null){
			final_dict["hostname"] = "ALL"
		}else{
			final_dict["hostname"] = hostname
		}
		
		
			
		return final_dict
	}


function getFlameGraphDictById(graphID){
	return flamegraphs_dict[graphID];
}
export function getFlameGraphDictByNum(graph_number){
	var graphID = flameGraphsIdBase + graph_number;
	return flamegraphs_dict[graphID];
}

export function changeFlamegraphSize(graph_number, graphX, graphY){
	var flamegraph_info = getFlameGraphDictByNum(graph_number) 
	flamegraph_info["sizeX"] = graphX
	flamegraph_info["sizeY"] = graphY
}


function reDrawFlameGraphByNumber(graph_number){
	var flamegraph_info = getFlameGraphDictByNum(graph_number)
	var graphID = flameGraphsIdBase + graph_number;
	var callback = function (response, graphID) {
		flamegraph_info["data"] = parseResponseFlamegraphData(response, graphID)
		drawFlameGraph(flamegraph_info["data"], graphID, true);
	};
	getFlameGraphData(createFlamegraphJson(flamegraph_info["start_time"], flamegraph_info["end_time"], flamegraph_info["hostname"]), graphID, callback)
}

function changeFlameGraphValues(graph_number, start_time, end_time, hostname){
	var flamegraph_info = getFlameGraphDictByNum(graph_number)
	flamegraph_info["start_time"] = start_time
	flamegraph_info["end_time"] = end_time
	flamegraph_info["hostname"] = hostname
}


export function drawFlameGraph(parsedData, graphID, dataHasChanged){
	
	var flamegraph_info = getFlameGraphDictById(graphID)
	var profile = convert(parsedData.profile, allStates);

	
	
	var g_width = flamegraph_info["sizeX"]
	var g_height = flamegraph_info["sizeY"]
    
    var margin = {top: 30, right: 40, bottom: 0, left: 0};
	var width = +g_width - margin.left - margin.right;
	var height = +g_height - margin.top - margin.bottom;
	
	
	
	var tooltip = function(d) {
	  return d.name + " <br /><br /> " + d.value + " samples<br /> " + (((d.value / profile.value) * 100).toFixed(2)) + "% of total";
	};

	var	svg =  d3.select("#" + graphID)
	if (svg.empty()){
	  svg = d3.select("#" + graphsContainerId)
		.append("div")
			.attr("id","containerFlamegraph_" + graphID)
			.attr("class", "resize-container")
			.append("div")
				.attr("class", "resize-drag")
				.attr("id","containerResizableFlamegraph_" + graphID)
				.append("svg")
					.attr("id", graphID)
					.attr("width", width)
					.attr("height", height);
	}else{
		svg.selectAll("g").remove()
		svg.selectAll("text").remove()
		svg.selectAll("rect").remove()
	}

		svg.transition().duration(500)
	  .attr('width', width + margin.left + margin.right)
	  .attr('height', height + margin.top + margin.bottom)
	
    var flameGraph = d3.flameGraph('#' + graphID, profile, true).size([width, height]).cellHeight(20).zoomEnabled(true).tooltip(tooltip).render();
}

function addFlameGraph(){
	//Generate the ID string of the graph
	var graphID = flameGraphsIdBase + flameGraph_counter;
	
	//Increment the counter of graphs displayed
	flameGraph_counter = flameGraph_counter + 1

	//Store all the graph data and metadata
	flamegraphs_dict[graphID] = {};
	var flamegraph_info = flamegraphs_dict[graphID];
	flamegraph_info["start_time"] = defaultFlamegraphsStartTime
	flamegraph_info["end_time"] = defaultFlamegraphsEndTime
	flamegraph_info["hostname"] = defaultFlamegraphsHostname
	
	flamegraph_info["sizeX"] = +defaultXSize
	flamegraph_info["sizeY"] = +defaultYSize
	
	var callback = function (response, graphID) {
		flamegraph_info["data"] = parseResponseFlamegraphData(response, graphID)
		drawFlameGraph(flamegraph_info["data"], graphID, true);
	};
	//AJAX call
	getFlameGraphData(createFlamegraphJson(flamegraph_info["start_time"], flamegraph_info["end_time"], flamegraph_info["hostname"]), graphID, callback)
}


function parseResponseFlamegraphData(allFlamegraphData, graphID){
		return allFlamegraphData
	}



//######## AJAX AND HTTP CALLS ############
	function getFlameGraphData(json, graphID, callback){
		var url = document.getElementById("config_form").elements.endpoint_MongoDB.value
		if (url === "undefined" || url === ""){
				url = defaultFlamegraphsURL
		}
		
		var xhr = createCORSRequest('GET', url + '?'+'start_time='+json["start_time"]+'&'+'end_time='+json["end_time"]+'&'+'hostname='+json["hostname"]);
		if (!xhr) {
		  throw new Error('CORS not supported');
		  return;
		}
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.setRequestHeader('Accept', 'application/json');
		
		xhr.onload = function() {
			if (xhr.status === 200) {
				var response = JSON.parse(xhr.responseText);
				//var graph_info = flamegraphs_dict[graphID];
				//graph_info["data"] = response
				callback(response, graphID)
			}else{
				var response = JSON.parse(xhr.responseText);
				//console.log(response)
				alert("Error getting graph data")
			}
		};
		
		xhr.onerror = function() {
			alert('Woops, there was an error making the request.');
		};
		
		//console.log(JSON.stringify(json))
		xhr.send();

	}
	
//####################################
