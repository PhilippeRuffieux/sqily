class Badge::Advisor < Badge
  Message::Text.after_create { Badge::Advisor.trigger(self) }

  def self.trigger(message)
    return unless message.to_workspace_id
    return unless (user = message.from_user)
    return unless (membership = user.memberships.where(community: message.to_workspace.community_id).first)
    return if where(membership: membership).exists?
    return if compute_score(membership) < required_count
    create!(membership: membership)
  end

  def self.required_count
    2
  end

  def self.compute_score(membership)
    workspace_ids = membership.user.workspace_partnerships.reader.joins(:workspace).where(workspaces: {community_id: membership.community_id}).pluck(:workspace_id)
    Message::Text.where(from_user: membership.user, to_workspace_id: workspace_ids).count("DISTINCT to_workspace_id")
  end

  def self.replay
    Message::Text.where.not(to_workspace_id: nil).find_each { |msg| trigger(msg) }
  end
end
