module UsersHelper
  def link_to_user(user, label = user.name, skill: nil, &block)
    attributes = {
      :class => "sidebar-open",
      "data-target" => users_path(current_community),
      "data-event" => "click->loadSideBar",
      :href => user_path(current_community, user, skill_id: skill.try(:id))
    }
    block ? content_tag(:span, attributes, &block) : content_tag(:span, label, attributes)
  end

  def user_avatar(user, options = {})
    image_tag(user_avatar_url(user), options.merge(class: "avatar", alt: "#{user.name} avatar."))
  end

  def user_avatar_url(user)
    user.avatar_url || gravatar_url(user.email)
  end

  def gravatar_url(email)
    "https://www.gravatar.com/avatar/" + Digest::MD5.hexdigest(email.downcase) + "?d=identicon"
  end

  def is_user_moderator?(user)
    current_community.memberships.where(user_id: user.id).first.try(:moderator)
  end

  def is_user_online?(user)
    user.last_activity_at && user.last_activity_at > 1.minutes.ago
  end

  def user_current_community_subscriptions(user)
    user.subscriptions.in_community(current_community)
  end

  def users_autocomplete_list(users)
    users.order(:name).pluck(:id, :name).map { |row| {id: row[0], name: row[1]} }.to_json
  end

  def users_autocomplete_list_for_message(message)
    if message.to_community_id
      users_autocomplete_list(message.to_community.users)
    elsif message.to_skill_id
      users_autocomplete_list(message.to_skill.users)
    elsif message.to_workspace
      users_autocomplete_list(message.to_workspace.users)
    else
      users_autocomplete_list(User.none)
    end
  end

  def users_autocomplete_list_for_workspace(workspace)
    users_autocomplete_list(workspace.community.users.where.not(id: workspace.users.pluck(:id)))
  end

  def user_messages_in_current_community(user)
    Message::Text.from_user(user).in_community(current_community)
  end

  def user_votes_in_current_community(user)
    Vote.from_user(user).in_community(current_community)
  end

  def user_evaluations_in_current_community(user)
    Evaluation.from_user(user).where(skill: current_community.skills.pluck(:id))
  end

  def user_subscriptions_in_current_community(user)
    Subscription.validated_by(user).in_community(current_community)
  end

  def current_community_subscriptions_validated_by_user(user)
    skill_ids = Skill.where(community_id: current_community.id).published.pluck(:id)
    Subscription.where(skill_id: skill_ids, validator_id: user.id).where.not(user_id: user.id)
  end

  def users_next_page_url(users)
    return if users.empty?
    next_page = (params[:page].to_i == 0) ? 2 : params[:page].to_i + 1
    if @skill
      users_list_path(current_community, page: next_page, skill_id: @skill.id, query: params[:query])
    else
      users_list_path(current_community, page: next_page, query: params[:query])
    end
  end

  def users_list(page)
    scope = nil
    if @skill
      scope = @skill.users.order_by_skill_ranking(@skill)
      scope = scope.joins(:memberships).by_team(current_team) if current_team
    else
      scope = current_community.users.order_by_community_ranking(current_community)
      scope = scope.by_team(current_team) if current_team
    end
    scope = scope.search_by_name(params[:query]) if params[:query].present?
    scope.page(page)
  end

  def user_list_for_tree?
    action_name == "tree" || request.referer.try(:include?, "/tree")
  end

  def has_user_pinned_skill?(user, skill)
    return false unless skill
    @has_user_pinned_skill_cache ||= {}
    @has_user_pinned_skill_cache["#{user.id}-#{skill.id}"] ||= Subscription.where(user_id: user.id, skill_id: skill.id).pluck(:pinned_at).first
  end
end
