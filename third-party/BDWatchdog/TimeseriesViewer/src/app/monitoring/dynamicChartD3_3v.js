import {max_range, min_range, applyScale, x_time_reduction_factor, defaultXSize, defaultYSize} from "./timeseries.js"



let grayscaleColors = d3.scale.category10().range()
//grayscaleColors = ["#000000", "#787878","#C0C0C0"]
//grayscaleColors = ["#000000", "#A9A9A9"]
//grayscaleColors = ["#000063", "#ffae51"]

function log(text) {
  if (console && console.log) console.log(text);
  return text;
}


/*****
 * Really simple tooltip implementation.
 * I may build upon it, but really trying to keep it minimal.
 *****/

export let nv = {models: {}};


nv.models.legend = function() {
  var margin = {top: 5, right: 0, bottom: 5, left: 10},
      width = 400,
      height = 20,
      // color = d3.scale.category10().range(), 
      color = grayscaleColors,
      dispatch = d3.dispatch('legendClick', 'legendMouseover', 'legendMouseout');


  function chart(selection) {
    selection.each(function(data) {
      /**
      *    Legend curently is setup to automaticaly expand vertically based on a max width.
      *    Should implement legend where EITHER a maxWidth or a maxHeight is defined, then
      *    the other dimension will automatically expand to fit, and anything that exceeds
      *    that will automatically be clipped.
      **/

      var wrap = d3.select(this).selectAll('g.legend').data([data]);
      var gEnter = wrap.enter().append('g').attr('class', 'legend').append('g');


      var g = wrap.select('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');


      var series = g.selectAll('.series')
          .data(function(d) { return d });
      var seriesEnter = series.enter().append('g').attr('class', 'series')
          .on('click', function(d, i) {
            dispatch.legendClick(d, i);
          });
      seriesEnter.append('circle')
          .style('fill', function(d, i){ return d.color || color[i % 10] })
          .style('stroke', function(d, i){ return d.color || color[i % 10] })
          .attr('r', 5);
      seriesEnter.append('text')
          .text(function(d) { return d.label })
          .attr('text-anchor', 'start')
          .attr('dy', '.32em')
          .attr('dx', '8');
      series.classed('disabled', function(d) { return d.disabled });
      series.exit().remove();


      var ypos = 5,
          newxpos = 5,
          maxwidth = 0,
          xpos;
      series
          .attr('transform', function(d, i) {
             var length = d3.select(this).select('text').node().getComputedTextLength() + 28;
             xpos = newxpos;

             //TODO: 1) Make sure dot + text of every series fits horizontally, or clip text to fix
             //      2) Consider making columns in line so dots line up
             //         --all labels same width? or just all in the same column?
             //         --optional, or forced always?
             if (width < margin.left + margin.right + xpos + length) {
               newxpos = xpos = 5;
               ypos += 20;
             }

             newxpos += length;
             if (newxpos > maxwidth) maxwidth = newxpos;

             return 'translate(' + xpos + ',' + ypos + ')';
          });

      //position legend as far right as possible within the total width
      g.attr('transform', 'translate(' + (width - margin.right - maxwidth) + ',' + margin.top + ')');

      height = margin.top + margin.bottom + ypos + 15;
    });

    return chart;
  }

  chart.dispatch = dispatch;

  chart.margin = function(_) {
    if (!arguments.length) return margin;
    margin = _;
    return chart;
  };

  chart.width = function(_) {
    if (!arguments.length) return width;
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) return height;
    height = _;
    return chart;
  };

  chart.color = function(_) {
    if (!arguments.length) return color;
    color = _;
    return chart;
  };

  return chart;
}


nv.models.line = function() {
  var margin = {top: 0, right: 0, bottom: 0, left: 0},
      width = defaultXSize, //960,
      height = defaultYSize, //500,
      dotRadius = function() { return 2.5 },
      // color = d3.scale.category10().range(), 
      color = grayscaleColors,      
      id = Math.floor(Math.random() * 10000), //Create semi-unique ID incase user doesn't select one
      x = d3.scale.linear(),
      y = d3.scale.linear(),
      dispatch = d3.dispatch("pointMouseover", "pointMouseout"),
      x0, y0;


  function chart(selection) {
    selection.each(function(data) {
      var seriesData = data.map(function(d) { return d.data });

      x0 = x0 || x;
      y0 = y0 || y;

      //TODO: reconsider points {x: #, y: #} instead of [x,y]
      //TODO: data accessors so above won't really matter, but need to decide for internal use

      //add series data to each point for future ease of use
      data = data.map(function(series, i) {
        series.data = series.data.map(function(point) {
          point.series = i;
          return point;
        });
        return series;
      });


		if(applyScale){
			y.domain([min_range,max_range])
			.range([height - margin.top - margin.bottom, 0]);

		}else{
			y.domain(d3.extent(d3.merge(seriesData), function(d) { return d[1] } ))
			.range([height - margin.top - margin.bottom, 0]);
		}

      x   .domain(d3.extent(d3.merge(seriesData), function(d) { return d[0] } ))
          .range([0, width - margin.left - margin.right]);

      //~ y   .domain(d3.extent(d3.merge(seriesData), function(d) { return d[1] } ))
          //~ .range([height - margin.top - margin.bottom, 0]);

      //~ y   .domain([0,d3.max(d3.merge(series), function(d) { return d[1] } )])
          //~ .range([height - margin.top - margin.bottom, 0]);

      //~ y   .domain([0,400])
          //~ .range([height - margin.top - margin.bottom, 0]);
          

      var vertices = d3.merge(data.map(function(line, lineIndex) {
            return line.data.map(function(point, pointIndex) {
              var pointKey = line.label + '-' + point[0];
              return [x(point[0]), y(point[1]), lineIndex, pointIndex]; //adding series index to point because data is being flattened
            })
          })
      );


      var wrap = d3.select(this).selectAll('g.d3line').data([data]);
      var gEnter = wrap.enter().append('g').attr('class', 'd3line').append('g');

      gEnter.append('g').attr('class', 'lines');
      gEnter.append('g').attr('class', 'point-clips');
      gEnter.append('g').attr('class', 'point-paths');


      var g = wrap.select('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

      var voronoi = d3.geom.voronoi(vertices).map(function(d,i) {
          return { 'data': d, 'series': vertices[i][2], 'point': vertices[i][3] }
      });

      var lines = wrap.select('.lines').selectAll('.line')
          .data(function(d) { return d }, function(d) { return d.label });
      lines.enter().append('g')
          .style('stroke-opacity', 1e-6)
          .style('fill-opacity', 1e-6);
      d3.transition(lines.exit())
          .style('stroke-opacity', 1e-6)
          .style('fill-opacity', 1e-6)
          .remove();
      lines.attr('class', function(d,i) { return 'line line-' + i })
          .classed('hover', function(d) { return d.hover })
          .style('fill', function(d,i) { return color[i % 10] })
          .style('stroke', function(d,i) { return color[i % 10] })
      d3.transition(lines)
          .style('stroke-opacity', 1)
          .style('fill-opacity', .5);


      var paths = lines.selectAll('path')
          .data(function(d, i) { return [d.data] });
      paths.enter().append('path')
          .attr('d', d3.svg.line()
            .x(function(d) { return x0(d[0]) })
            .y(function(d) { return y0(d[1]) })
          );
      paths.exit().remove();
      d3.transition(paths)
          .attr('d', d3.svg.line()
            .x(function(d) { return x(d[0]) })
            .y(function(d) { return y(d[1]) })
          );

    });

    x0 = x;
    y0 = y;

    return chart;
  }



  nv.strip = function(s) {
    return s.replace(/(\s|&)/g,'');
  }


  chart.dispatch = dispatch;

  chart.margin = function(_) {
    if (!arguments.length) return margin;
    margin = _;
    return chart;
  };

  chart.width = function(_) {
    if (!arguments.length) return width;
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) return height;
    height = _;
    return chart;
  };

  chart.color = function(_) {
    if (!arguments.length) return color;
    color = _;
    return chart;
  };

  chart.id = function(_) {
    if (!arguments.length) return id;
    id = _;
    return chart;
  };


  return chart;
}


nv.models.lineWithLegend = function() {
  var margin = {top: 40, right: 10, bottom: 60, left: 60},
      width = defaultXSize, //960,
      height = defaultYSize, //500,
      dotRadius = function() { return 2.5 },
      xAxisLabelText = false,
      yAxisLabelText = false,
      // color = d3.scale.category10().range(), 
      color = grayscaleColors,
      dispatch = d3.dispatch('showTooltip', 'hideTooltip');

  var x = d3.scale.linear(),
      y = d3.scale.linear(),
      xAxis = d3.svg.axis().scale(x).orient('bottom'),
      yAxis = d3.svg.axis().scale(y).orient('left'),
      legend = nv.models.legend().height(margin.top).color(color),
      lines = nv.models.line();


  function chart(selection) {
    selection.each(function(data) {
      var series = data.filter(function(d) { return !d.disabled })
            .map(function(d) { return d.data });

			x.domain(d3.extent(d3.merge(series), function(d) { return d[0]/x_time_reduction_factor } ))
				.range([0, width - margin.left - margin.right]);


		if(applyScale){
			y.domain([min_range, max_range])
			.range([height - margin.top - margin.bottom, 0]);

		}else{
			y.domain(d3.extent(d3.merge(series), function(d) { return d[1] } ))
			.range([height - margin.top - margin.bottom, 0]);
		}

      //~ y   .domain(d3.extent(d3.merge(series), function(d) { return d[1] } ))
          //~ .range([height - margin.top - margin.bottom, 0]);

      //~ y   .domain([0,d3.max(d3.merge(series), function(d) { return d[1] } )])
          //~ .range([height - margin.top - margin.bottom, 0]);

      //~ y   .domain([0,400])
          //~ .range([height - margin.top - margin.bottom, 0]);
          
      lines
        .width(width - margin.left - margin.right)
        .height(height - margin.top - margin.bottom)
        .color(data.map(function(d,i) {
          return d.color || color[i % 10];
        }).filter(function(d,i) { return !data[i].disabled }))

      xAxis
        .ticks( width / 50 )
        .tickSize(-(height - margin.top - margin.bottom), 0);
      yAxis
        .ticks( height / 50 )
        .tickSize(-(width - margin.right - margin.left), 0);


      var wrap = d3.select(this).selectAll('g.wrap').data([data]);
      var gEnter = wrap.enter().append('g').attr('class', 'wrap d3lineWithLegend').append('g');

      gEnter.append('g').attr('class', 'legendWrap');
      gEnter.append('g').attr('class', 'x axis');
      gEnter.append('g').attr('class', 'y axis');
      gEnter.append('g').attr('class', 'linesWrap');


      legend.dispatch.on('legendClick', function(d, i) { 
        d.disabled = !d.disabled;

        if (!data.filter(function(d) { return !d.disabled }).length) {
          data.forEach(function(d) {
            d.disabled = false;
          });
        }

        selection.transition().call(chart)
      });


      //~ legend.dispatch.on('legendMouseover', function(d, i) {
        //~ d.hover = true;
        //~ selection.transition().call(chart)
      //~ });

      //~ legend.dispatch.on('legendMouseout', function(d, i) {
        //~ d.hover = false;
        //~ selection.transition().call(chart)
      //~ });

      legend
          .color(color)
          .width(width - 2 * margin.right - 2*margin.left)
          
      wrap.select('.legendWrap')
          .datum(data)
          .attr('transform', 'translate(' + (margin.left) + ',' + (-legend.height()) +')')
          .call(legend);


      //TODO: maybe margins should be adjusted based on what components are used: axes, axis labels, legend
      //margin.top = legend.height();  //need to re-render to see update

      var g = wrap.select('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');



      var linesWrap = wrap.select('.linesWrap')
          .datum(data.filter(function(d) { return !d.disabled }));

      d3.transition(linesWrap).call(lines);



      var xAxisLabel = g.select('.x.axis').selectAll('text.axislabel')
          .data([xAxisLabelText || null]);
      xAxisLabel.enter().append('text').attr('class', 'axislabel')
          .attr('text-anchor', 'middle')
          .attr('x', x.range()[1] / 2)
          .attr('y', margin.bottom - 20);
      xAxisLabel.exit().remove();
      xAxisLabel.text(function(d) { return d });

      g.select('.x.axis')
          .attr('transform', 'translate(0,' + y.range()[0] + ')')
          .call(xAxis)
        .selectAll('line.tick')
        .filter(function(d) { return !d })
          .classed('zero', true);


      var yAxisLabel = g.select('.y.axis').selectAll('text.axislabel')
          .data([yAxisLabelText || null]);
      yAxisLabel.enter().append('text').attr('class', 'axislabel')
          .attr('transform', 'rotate(-90)')
          .attr('text-anchor', 'middle')
          .attr('y', 10 - margin.left);
      yAxisLabel.exit().remove();
      yAxisLabel
          .attr('x', -y.range()[0] / 2)
          .text(function(d) { return d });

      g.select('.y.axis')
          .call(yAxis)
        .selectAll('line.tick')
        .filter(function(d) { return !d })
          .classed('zero', true);
    });

    return chart;
  }

  chart.dispatch = dispatch;

  chart.margin = function(_) {
    if (!arguments.length) return margin;
    margin = _;
    return chart;
  };

  chart.width = function(_) {
    if (!arguments.length) return width;
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) return height;
    height = _;
    return chart;
  };

  chart.color = function(_) {
    if (!arguments.length) return color;
    color = _;
    return chart;
  };

  chart.dotRadius = function(_) {
    if (!arguments.length) return dotRadius;
    dotRadius = d3.functor(_);
    lines.dotRadius = d3.functor(_);
    return chart;
  };

  //TODO: consider directly exposing both axes
  //chart.xAxis = xAxis;

  //Expose the x-axis' tickFormat method.
  chart.xAxis = {};
  d3.rebind(chart.xAxis, xAxis, 'tickFormat');

  chart.xAxis.label = function(_) {
    if (!arguments.length) return xAxisLabelText;
    xAxisLabelText = _;
    return chart;
  }

  // Expose the y-axis' tickFormat method.
  //chart.yAxis = yAxis;

  chart.yAxis = {};
  d3.rebind(chart.yAxis, yAxis, 'tickFormat');

  chart.yAxis.label = function(_) {
    if (!arguments.length) return yAxisLabelText;
    yAxisLabelText = _;
    return chart;
  }

  return chart;
}
