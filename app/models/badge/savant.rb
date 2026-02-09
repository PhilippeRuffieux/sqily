class Badge::Savant < Badge
  Skill.after_create { Badge::Savant.trigger(self) }

  def self.trigger(skill)
    return unless (membership = Membership.where(community: skill.community, user: skill.creator).first)
    return if where(membership: membership).exists?
    create!(membership: membership)
  end

  def self.required_count
    1
  end

  def self.compute_score(membership)
    Skill.where(creator_id: membership.user_id).count
  end

  def self.replay
    Skill.find_each { |s| trigger(s) }
  end
end
