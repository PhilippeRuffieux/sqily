class SkillForm
  attr_reader :result, :skill

  def self.create(params)
    (form = new).create(params)
    form
  end

  def self.update(skill, params)
    (form = new).update(skill, params)
    form
  end

  def create(params)
    filter_param_parent_id(params)
    user = params[:creator]
    tasks_params = params.delete(:tasks)
    build_tasks(@skill = Skill.new(params), tasks_params)
    if @skill.save
      @skill.remove_foreign_prerequisites
      Subscription.create!(user: user, skill: skill, completed_at: Time.now)
      Message::NewSkill.trigger(skill)
    end
    @result = skill.persisted?
  end

  def update(skill, params)
    filter_param_parent_id(params, skill)
    update_or_create_tasks(skill, params.delete(:tasks))
    if (@result = skill.update(params))
      skill.remove_foreign_prerequisites
      Message::NewSkill.trigger(skill)
    end
    @result
  end

  private

  def build_tasks(skill, tasks_params)
    (tasks_params || []).each do |hash|
      skill.tasks.new(hash)
    end
  end

  def update_or_create_tasks(skill, tasks_params)
    return unless tasks_params
    tasks_params.each do |hash|
      if (task = skill.tasks.find_by_id(hash[:id]))
        task.update(hash)
      else
        skill.tasks.create(hash)
      end
    end
  end

  def filter_param_parent_id(params, skill = nil)
    if params[:parent_id].present?
      community = skill.try(:community) || params[:community]
      parent = community.skills.roots.find_by_id(params[:parent_id])
      params.delete(:parent_id) if !parent || !parent.can_have_children?
    end
  end
end
