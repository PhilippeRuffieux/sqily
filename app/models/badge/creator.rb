class Badge::Creator < Badge
  Evaluation.after_create { Badge::Creator.trigger(self) }

  def self.trigger(evaluation)
    return unless (membership = Membership.where(user: evaluation.user_id, community: evaluation.skill.community_id).first)
    return if where(membership: membership).exists?
    return if compute_score(membership) < required_count

    create!(membership: membership)
  end

  def self.required_count
    2
  end

  def self.compute_score(membership)
    skill_ids = Skill.where(community: membership.community_id).pluck(:id)
    Evaluation.where(skill: skill_ids, user: membership.user_id).count
  end

  def self.replay
    Evaluation.find_each { |e| trigger(e) }
  end
end
