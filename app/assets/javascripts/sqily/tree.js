SVGElement.prototype.getTransformToElement = SVGElement.prototype.getTransformToElement || function(toElement) {
    return toElement.getScreenCTM().inverse().multiply(this.getScreenCTM());
}

Sqily.Tree = function(container) {
  this.render();
}

Sqily.Tree.prototype.build = function() {
}

Sqily.Tree.prototype.render = function() {
  var svg = document.getElementById("tree-svg");

  var g = new dagreD3.graphlib.Graph({compound: true})
    .setGraph({acyclicer: "greedy", ranker: "tight-tree", rankdir: "LR", align: "UL", nodesep:48, edgesep:8, ranksep:24, marginx:8, marginy:8})
    .setDefaultEdgeLabel(function() { return {}; });

  var json = JSON.parse(svg.getAttribute("data-json"));
  json.forEach(function(skill) {
    var css;
    css = skill.status;
    if (skill.children > 0)
      css = css + " skill-group";
    g.setNode(skill.id,  {labelType: "html", label: skill.label, class: css});
    skill.prerequisites.forEach(function(prerequisite) {
      var css;
      if (prerequisite.mandatory)
        css = "lock";
      else if (skill.minimum_prerequisites > 0)
        css = "halflock";
      var parentSkill = Sqily.Tree.findSkillByid(json, prerequisite.from_skill_id);
      if (parentSkill.status == "finish")
        css += " completed";
      g.setEdge(prerequisite.from_skill_id, skill.id, {weight: 100, lineInterpolate: 'basis', arrowhead: "customArrow", class: css});
    })
  });

  // Round the corners of the nodes
  g.nodes().forEach(function(v) {
    var node = g.node(v);
    node.rx = node.ry = 8;
  });

  var render = new dagreD3.render();

  // Add our custom arrow
  render.arrows().customArrow = function normal(parent, id, edge, type) {
    var marker = parent.append("marker")
      .attr("id", id)
      .attr("viewBox", "0 0 10 10")
      .attr("refX", 8)
      .attr("refY", 5)
      .attr("markerUnits", "strokeWidth")
      .attr("markerWidth", 8)
      .attr("markerHeight", 6)
      .attr("orient", "auto");

    var path = marker.append("path")
      .attr("d", "M 0 0 L 10 5 L 0 10 z")
      .style("stroke-width", 0)
      .style("stroke-dasharray", "1,0")
    dagreD3.util.applyStyle(path, edge[type + "Style"]);
  };


  // Set up an SVG group so that we can translate the final graph.
  var svg = d3.select("#tree-svg");
  var svgGroup = svg.append("g");
  // Run the renderer. This is what draws the final graph.
  render(d3.select("#tree-svg g"), g);

  // Set the graph size
  svg.attr("width", g.graph().width);
  svg.attr("height", g.graph().height);
}

Sqily.Tree.findSkillByid = function(skills, skillId) {
  return skills.find(function(skill) {
    return skill.id == skillId;
  });
}
