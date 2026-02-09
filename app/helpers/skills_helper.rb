module SkillsHelper
  def user_skill_state(skill, user)
    return if !skill || !user
    @user_skill_state_cache ||= {}
    unless @user_skill_state_cache[key = "#{skill.id}-#{user.id}"]
      array = user.subscriptions.where(skill_id: skill.id).pluck(:completed_at)
      @user_skill_state_cache[key] = if array.empty?
        ""
      else
        array.first ? "finish" : "start"
      end
    end
    @user_skill_state_cache[key]
  end

  def subscription_state(subscription)
    if subscription
      subscription.completed_at ? "finish" : "start"
    end
  end

  def user_subscription_states(users, skill)
    rows = Subscription.where(skill_id: @skill.id, user_id: users.map(&:id)).pluck(:user_id, :completed_at, :pinned_at)
    rows.each_with_object({}) do |row, hash|
      hash[row[0]] = {completed_at: row[1], pinned_at: row[2], state: row[1] ? "finish" : "start"}
    end
  end

  def subscription_human_state(subscription)
    if subscription
      subscription.completed_at ? "vous êtes expert" : "vous êtes inscrit"
    else
      "vous n'êtes pas inscrit"
    end
  end

  def skill_completed_by?(skill, user)
    skill.subscriptions.where(user_id: user.id).pluck(:completed_at).first
  end

  def subscription_new_messages?(subscription)
    if subscription&.last_read_at
      if (last_message_created_at = subscription.skill.messages.last.try(:created_at))
        subscription.last_read_at < last_message_created_at
      end
    end
  end

  def current_community_skills
    current_community.skills.roots.viewable_by(current_user).select(
      "skills.*, (SELECT COUNT(subscriptions.id) FROM subscriptions WHERE subscriptions.skill_id = skills.id) AS subscription_count, " \
      "(SELECT COUNT(subscriptions.id) FROM subscriptions WHERE subscriptions.skill_id = skills.id AND completed_at IS NOT NULL) AS completed_subscription_count"
    )
  end

  def skill_to_tree_json(skills, relative_to_user = nil)
    skills.map do |skill|
      relevant_skill_path = skill_path(current_community, skill, community_tree: params[:community_tree])
      {
        id: skill.id,
        name: skill.name,
        group: skill.group_name,
        status: skill_tree_stastus(skill, relative_to_user),
        minimum_prerequisites: skill.minimum_prerequisites,
        children: skill.children.size,
        url: relevant_skill_path,
        label: link_to(skill_tree_label(skill), relevant_skill_path),
        prerequisites: skill.prerequisites.published.map { |prerequisite|
          {from_skill_id: prerequisite.from_skill_id, mandatory: prerequisite.mandatory}
        }
      }
    end.to_json
  end

  def skill_tree_label(skill)
    icon = Octicons::Octicon.new("star")
    str = "<span class='skill__name'>#{h(skill.name)}</span>"
    # str += user_avatar(current_user) if current_user
    if skill.children.size > 0
      str += "<span class='group-skill__count'>#{icon.to_svg} #{h(skill.children.size)}</span></span>"
    end
    str.html_safe
  end

  def skill_user_and_expert_counts(skill)
    users = I18n.t("communities.tree.skill_user_count", count: skill.subscriptions.count)
    experts = I18n.t("communities.tree.skill_expert_count", count: skill.subscriptions.completed.count)
    I18n.t("communities.tree.skill_label", user_count: users, expert_count: experts)
  end

  def skill_tree_stastus(skill, user)
    if user
      user_skill_state(skill, user) || (skill.startable_by?(user) ? nil : "lock")
    else
      experts = skill.subscriptions.completed.count.to_f
      rounded_percentage = (experts > 0) ? ((experts / skill.subscriptions.count) * 10).round * 10 : 0
      proportion = "skill-#{rounded_percentage}-percent-of-experts"
      skill.prerequisites.mandatory.exists? ? proportion + " lock" : proportion
    end
  end

  def skill_creator_or_first_expert(skill)
    skill.creator || skill.subscriptions.completed.order(:completed_at).first.try(:user)
  end

  def skill_description_placeholder
    <<-EOS.squeeze(" ")
      exemple :
      - Maîtriser les outils de capture vidéo sur l'ordinateur ou à l'aide d'un instrument externe (caméra, smartphone)
      - Gérer le contenu en rapport aux objectif visés par la capsule
      - Utiliser le storyboard pour gérer le déroulement de la capsule
      - Prendre en compte les aspects du droit à l'image
      - Maîtriser les bases de la prise de vue (cadrage, lumière, prise de son)
      - Maîtriser le ton du discours
    EOS
  end

  def skill_long_description?(skill)
    lines = skill.description.scan("<br>").count
    images = skill.description.scan("<img ").count
    images > 0 || lines > 5
  end

  def skill_description_summary(skill)
    strip_tags(skill.description.gsub("<br>", "\n"))[0, 200]
  end

  def format_skill_description(skill)
    format_rich_text(skill.description.html_safe)
  end

  def skill_parent_options(selected_id)
    skills = current_community.skills.roots.order_by_name.to_a.keep_if(&:can_have_children?)
    options_from_collection_for_select(skills, :id, :name, selected_id)
  end
end
