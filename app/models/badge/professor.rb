class Badge::Professor < Badge
  Homework.after_update { Badge::Professor.trigger(self) }

  def self.trigger(homework)
    return if !homework.approved_at
    community = homework.subscription.skill.community
    membership = Membership.where(user: homework.evaluation.user_id, community: community).first
    return unless (membership = Membership.where(user: homework.evaluation.user_id, community: community).first)
    return if where(membership: membership).exists?
    return if compute_score(membership) < required_count
    create!(membership: membership)
  end

  def self.required_count
    20
  end

  def self.compute_score(membership)
    Homework.from_community(membership.community).to_approver(membership.user_id).approved.count
  end

  def self.replay
    Homework.find_each { |h| trigger(h) }
  end
end
