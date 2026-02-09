Sqily.SkillFilters = function() {
  var filters = document.querySelectorAll("[data-skills-filter]");

  Array.prototype.forEach.call(filters, function(filter) {
    filter.addEventListener("click", function(event) {
      var skillCount = 0;
      var active = !filter.classList.contains("active");
      var filterState = filter.getAttribute("data-skills-filter");
      Array.prototype.forEach.call(filters, function(filter) { filter.classList.remove("active") });
      Array.prototype.forEach.call(document.querySelectorAll("#skills [data-skill-state]"), function(skill) {
        var skillState = skill.getAttribute("data-skill-state")
        if (!active || skillState == filterState || (filterState != "" && skillState.includes(filterState))) {
          skill.style.display = null;
          skillCount++;
        }
        else
          skill.style.display = "none";
      });
      active && filter.classList.add("active")
      document.getElementById("skill-count").textContent = skillCount;
    });
  });
}
