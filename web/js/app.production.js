(function(){var q,m,n,s,t,l,r,o,u,v=Array.prototype.slice,w=this,x=Object.prototype.hasOwnProperty,p=function(d,b){function c(){this.constructor=d}for(var a in b)x.call(b,a)&&(d[a]=b[a]);c.prototype=b.prototype;d.prototype=new c;d.__super__=b.prototype;return d};m=function(d){var b;b=Q.defer();d3.json(d,function(c){return b.resolve(c)});return b.promise};q=r=null;this.app={api:{fetchDistributionAverage:function(d){null==d&&(d=19);return(q&&Q.call(function(){return q})||m("data/_average_distributions.json")).then(function(b){var c,
a;q=b;return _.max(function(){var d;d=[];for(c in b)a=b[c][0],d.push(a);return d}())})},fetchDistributions:function(d){null==d&&(d=19);return m("data/distributions.json").then(function(b){return{name:"Root",children:b}})},fetchOccurencies:function(d,b){null==b&&(b=19);return this._fetchOccurencyAverages(b).then(function(c){d=encodeURIComponent(d.replace(/\//g,"-"));return m("data/"+d+"_co-occurrencies.json").then(function(a){return[a[b.toString()],c]})})},_fetchOccurencyAverages:function(d){null==
d&&(d=19);return(r&&Q.call(function(){return r})||m("/data/_average_co-occurencies.json")).then(function(b){r=b;return b[d]})}}};this.app.__defineGetter__("ciclo",function(){return this._ciclo||"19"});this.app.__defineSetter__("ciclo",function(d){return this._ciclo=d});s=function(d){return d.__data__};this.app.Delegator=function(){function d(b,c){this.element=b;this.options=null!=c?c:{};"string"===typeof this.element&&(this.element=document.querySelector(this.element));this.bindEvents()}d.prototype.bindEvents=
function(){var b,c,a,d,e,j,f,g;if(this.events){j=this.events;g=[];for(a in j)c=j[a],f=a.split(" "),d=2<=f.length?v.call(f,0,e=f.length-1):(e=0,[]),b=f[e++],g.push(this.addEvent(d.join(" "),b,c));return g}};d.prototype.addEvent=function(b,c,a){var d,e=this;d=function(){return e[a].apply(e,arguments)};return this.element.addEventListener(c,function(a){var c;c=b?e.element.querySelectorAll(b):[e.element];if(_.include(c,a.target))return d(a,s(a.target))})};return d}();app.utils={applyAll:function(d,b,
c){null==c&&(c=null);return _.each(d,function(a){return a.apply(c||w,b)})}};this.app.Slider=function(d){function b(c,a){b.__super__.constructor.call(this,c,a);this.graph=a.graph}p(b,d);b.prototype.events={mouseup:"onMouseUp"};b.prototype.onMouseUp=function(c){c.target.parentElement.querySelector("output").value=c.target.value;app.ciclo=c.target.value;return this.graph.update()};return b}(this.app.Delegator);n=function(d){for(;d.parent&&"Root"!==d.parent.name;)d=d.parent;return d};u=function(d){d.fill0=
d3.select(this).style("fill");d.x0=d.x;return d.dx0=d.dx};o=function(d){var b;return(null!=d?null!=(b=d.frequencies)?b[app.ciclo]:void 0:void 0)||0};this.app.SunburstGraph=function(d){function b(c,a,d){this.data=c;this.element=null!=a?a:"#chart";this.options=null!=d?d:{};_.defaults(this.options,{width:700,height:700});c=Math.min(this.options.width,this.options.height)/2;this.vis=d3.select(this.element).append("svg").attr("width",this.options.width).attr("height",this.options.height).append("g").attr("transform",
"translate("+this.options.width/2+","+this.options.height/2+")");this.partition=d3.layout.partition().sort(function(a,c){var b;return(null!=c?null!=(b=c.frequencies)?b[app.ciclo]:NaN:NaN)-a.frequencies[app.ciclo]||1}).size([2*Math.PI,c*c]).value(o);this.arc=d3.svg.arc().startAngle(function(a){return a.x}).endAngle(function(a){return a.x+a.dx}).innerRadius(function(a){return Math.sqrt(a.y)}).outerRadius(function(a){return Math.sqrt(a.y+a.dy)});this.tooltip=new app.Tooltip({graph:this});this.barchartPanel=
this.options.barchartPanel;this.setColourScales();b.__super__.constructor.call(this,this.element,this.options)}p(b,d);b.prototype.events={"path mouseover":"onMouseover","path mouseout":"onMouseout","path click":"onClick","path mousemove":"onMousemove"};b.prototype.render=function(){var c=this;this.vis.data([this.data]).selectAll("path").data(this.partition.nodes).enter().append("g");this.vis.selectAll("g").append("path").attr("display",function(a){return a.depth&&3>a.depth?null:"none"}).attr("d",
this.arc).attr("fill-rule","evenodd").style("stroke","#fff").style("fill",function(a){if(0<a.depth)return a=n(a),"hsl(0, 0%, "+c.colourScales.level(a.frequencies[app.ciclo])+"%)"}).each(u);return this};b.prototype.setColourScales=function(){var c,a,b,d;b=function(){var c,b,d,e;d=this.data.children;e=[];for(c=0,b=d.length;c<b;c++)a=d[c].name,e.push(a);return e}.call(this);d=function(){var a,b,d,e;d=this.data.children;e=[];for(a=0,b=d.length;a<b;a++)c=d[a],e.push(o(c));return e}.call(this).sort(function(a,
c){return c-a});return this.colourScales={hue:d3.scale.ordinal().domain(b).rangePoints([0,359]),level:d3.scale.ordinal().domain(d).rangeRoundBands([0,100])}};b.prototype.update=function(){var c=this;this.setColourScales();return this.vis.selectAll("path").data(this.partition.value(o)).transition().duration(1E3).style("fill",function(a){a=n(a);return"hsl(0, 0%, "+c.colourScales.level(o(a))+"%)"}).attrTween("d",function(a){var b;b=d3.interpolate({x:a.x0,dx:a.dx0},a);return function(d){d=b(d);a.x0=d.x;
a.dx0=d.dx;return c.arc(d)}})};b.prototype.onMouseover=function(c,a){a.active||this._colouriseSector(a);return this.tooltip.show(a)};b.prototype.onMouseout=function(c,a){a.active||this._downlightSector(a);return this.tooltip.hide()};b.prototype.onClick=function(c,a){var b=this;this._downlightAll();return this._fetchRelatedSectors(a).then(function(c){var d;d=_.clone(a);d.colour=d3.hsl(b.colourScales.hue(a.parent.name),1,0.5).toString();b.barchartPanel.clear().render(d,c);return null},function(a){throw a;
})};b.prototype.onMousemove=function(c){return this.tooltip.move(c)};b.prototype._colouriseSector=function(c){var a;a=n(c);1===c.depth&&(c=a);a=d3.hsl(this.colourScales.hue(a.name),1,0.5);this.vis.selectAll("path").filter(function(a){return a===c||a.parent===c}).style("fill",a.toString());return this};b.prototype._downlightSector=function(c){this.vis.selectAll("path").filter(function(a){return a===c||a.parent===c}).style("fill",function(a){return a.fill0});return this};b.prototype._downlightAll=function(){this.vis.selectAll("path").style("fill",
function(c){return c.fill0}).each(function(c){return c.active=!1});return this};b.prototype._fetchRelatedSectors=function(c){var a=this;return app.api.fetchOccurencies(c.name,app.ciclo).then(function(c){var b,d,f,g,k,h,i;k=[];f=c[0];b=c[1];h=function(){var a;a=[];for(i in f)d=f[i],d>=b&&a.push([i,d]);return a}();g=function(){var a,c,b,e;e=[];for(a=0,c=h.length;a<c;a++)b=h[a],i=b[0],d=b[1],e.push(i);return e}();a.vis.selectAll("path").filter(function(a){return-1<g.indexOf(a.name)}).style("fill",function(c){var b;
b=n(c);b=d3.hsl(a.colourScales.hue(b.name),1,0.5).toString();k.push({colour:b,name:c.name,frequencies:c.frequencies,co_occurencies:f[c.name]});return b}).each(function(a){return a.active=!0});return k})};return b}(this.app.Delegator);l=null;t=function(d){var b,c,a;c=d.frequencies;a=[];for(b in c)d=c[b],a.push(d);return a};this.app.Barchart=function(d){function b(c,a){null==a&&(a={});_.defaults(a,{height:30,bar_width:30,colour:"grey"});l=d3.scale.linear().domain([0,parseInt(a.maxSectorFrequency)]).rangeRound([0,
a.height]);this.selection=d3.select(c).append("g").attr("class","barchart");b.__super__.constructor.call(this,this.selection.node(),a)}p(b,d);b.prototype.render=function(c){var a,b,d=this;a=t(c);b=[];this.selection.selectAll("rect").data(a).enter().append("rect").attr("x",function(a,c){return c*d.options.bar_width}).attr("y",function(a){return d.options.y+d.options.height-l(a)}).attr("width",this.options.bar_width).attr("height",function(a){a=l(a);b.push(a);return a});this.selection.append("rect").attr("x",
function(){return(app.ciclo-19)*d.options.bar_width}).attr("y",function(){return d.options.y+d.options.height-l(c.co_occurencies)}).attr("width",this.options.bar_width).attr("height",function(){return l(c.co_occurencies)}).style("fill",this.options.sector.colour);this.selection.append("text").attr("x",function(){return a.length*d.options.bar_width+10}).attr("y",function(){return d.options.y}).append("tspan").text(c.name).style("font-size",12).style("fill","#fff").node();this.selection.append("rect").attr("height",
18).attr("width",function(){return 10*c.name.trim().length}).attr("x",function(){return a.length*d.options.bar_width+8}).attr("y",function(){return d.options.y+25}).style("fill",c.colour);return this};b.prototype.remove=function(){return this.element.parentElement.removeChild(this.element)};return b}(this.app.Delegator);this.app.BarchartPanel=function(d){function b(c,a){_.defaults(a,{height:700,width:700,barchart_height:40,barchart_bar_width:20});this.selection=d3.select(c).append("svg").attr("width",
a.width).attr("height",a.height);this.charts=[];b.__super__.constructor.call(this,this.selection.node(),a)}p(b,d);b.prototype.render=function(c,a){var b,d,j,f,g,k,h,i,a=a.sort(function(a,c){return c.frequencies[app.ciclo]-a.frequencies[app.ciclo]});d=Math.round(this.options.height/this.options.barchart_height);k=function(){var a,c;c=[];for(f=0,a=d-1;0<=a?f<=a:f>=a;0<=a?f++:f--)c.push(this.options.barchart_height*f);return c}.call(this);b={height:this.options.barchart_height,bar_width:this.options.barchart_bar_width,
maxSectorFrequency:this.options.maxSectorFrequency,sector:c};for(h=0,i=k.length;h<i;h++)g=k[h],this.charts.push(new app.Barchart(this.element,_.extend({y:g},b)));for(j in a)b=a[j],this.charts[j].render(b);return this};b.prototype.clear=function(){var c,a,b,d;d=this.charts;for(a=0,b=d.length;a<b;a++)c=d[a],c.remove();this.charts=[];return this};return b}(this.app.Delegator);this.app.Tooltip=function(d){function b(c){null==c&&(c={});this.selection=d3.select("body").append("div").attr("class","tooltip");
this.graph=c.grap;b.__super__.constructor.call(this,this.selection.node(),c)}p(b,d);b.prototype.show=function(c){var a,b;b=c.human_name||c.name;b+=" ( "+(null!=c?null!=(a=c.frequencies)?a[app.ciclo]:void 0:void 0)+")";a=1===c.depth&&c||(null!=c?c.parent:void 0);1===c.depth&&(c=a);a=d3.hsl(this.options.graph.colourScales.hue(a.name),1,0.5);c&&b&&this.selection.text(b).style("visibility","visible").style("background",a.toString());return this};b.prototype.hide=function(){this.selection.style("visibility",
"hidden");return this};b.prototype.move=function(b){this.selection.style("top",b.pageY-10+"px").style("left",b.pageX+10+"px");return this};return b}(this.app.Delegator);document.addEventListener("DOMContentLoaded",function(){return app.api.fetchDistributions().then(function(d){app.api.fetchDistributionAverage(19).then(function(b){b=new app.BarchartPanel("#barchart-panel",{maxSectorFrequency:b});b=(new app.SunburstGraph(d,"#chart",{barchartPanel:b})).render();new app.Slider("#ciclo-slider",{graph:b});
return null},function(b){throw b;}).end();return d},function(d){throw d;}).end()})}).call(this);
