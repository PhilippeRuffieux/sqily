class Badge::Partner < Badge
  Vote.after_create { Badge::Partner.trigger(self) }

  def self.trigger(vote)
    msg = vote.message
    return unless (community = msg.to_community) || msg.to_skill.try(:community) || msg.to_workspace.try(:community)
    return unless (membership = Membership.where(community: community, user: msg.from_user_id).first)
    return if compute_score(membership) < required_count
    return if where(membership: membership).exists?
    create!(membership: membership)
  end

  def self.required_count
    5
  end

  def self.compute_score(membership)
    Vote.in_community(membership.community).to_user(membership.user_id).count
  end

  def self.replay
    Vote.find_each { |v| trigger(v) }
  end
end
