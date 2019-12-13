export let profilings = [];
const divProfilingFormsIdBase = 'profiling-form_';
var profilings_counter = 0;
var current_profiling_number = 0;
var profilings_form_html_filename = "html/profiling_form.html";


function addNewProfilingForm(){
	//Create the form html
	var newdiv = document.createElement('div');
	var divIdName = divProfilingFormsIdBase + profilings_counter;
	newdiv.setAttribute('id', divIdName);
	profilings.push(newdiv);
	newdiv.className += " profiling";
	current_profiling_number = profilings_counter
	profilings_counter = profilings_counter + 1	
	
	//Add the new metrics form to the container
	var theContainer = document.getElementById(formsContainerId);
	theContainer.appendChild(newdiv);
	$("#" + newdiv.id).load(profilings_form_html_filename, function() { // "html/form.html"

	});
	
	//Draw the associated graph
	addFlameGraph();
	
	disableQuickButtons();
	
	//Return the number of this new form
	return current_profiling_number
}

function submitFlamegraph(form) {
	var start_time = form.elements.datetime0.value
	start_time = new Date(start_time).getTime() /1000
	var end_time = form.elements.datetime1.value
	end_time = new Date(end_time).getTime() /1000
	var hostname = form.elements.hostname.value
	
	var graph_number = getNumFromForm(form);
	
	changeFlameGraphValues(graph_number, start_time, end_time, hostname)
	reDrawFlameGraphByNumber(graph_number)
}
