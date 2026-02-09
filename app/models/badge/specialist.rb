class Badge::Specialist < Badge
  Subscription.after_update { Badge::Specialist.trigger(self) }

  def self.trigger(subscription)
    return if !subscription.completed_at
    return unless (membership = Membership.where(user: subscription.user_id, community: subscription.skill.community_id).first)
    return if where(membership: membership).exists?
    return if compute_score(membership) < required_count
    create!(membership: membership)
  end

  def self.required_count
    5
  end

  def self.compute_score(membership)
    Subscription.completed.in_community(membership.community).where(user: membership.user_id).count
  end

  def self.replay
    Subscription.find_each { |s| trigger(s) }
  end
end
