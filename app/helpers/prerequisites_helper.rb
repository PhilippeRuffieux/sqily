module PrerequisitesHelper
  def available_prerequisites_skills_for(skill)
    if skill.parent
      skill.parent.children.order(:name) - skill.prerequisites.map(&:from_skill) - [skill]
    else
      current_community.skills.roots.order(:name).to_a - skill.prerequisites.map(&:from_skill) - [skill]
    end
  end
end
