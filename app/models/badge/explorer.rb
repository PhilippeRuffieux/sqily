class Badge::Explorer < Badge
  Message::Upload.after_create { Badge::Explorer.trigger(self) }

  def self.trigger(message)
    return unless (community_id = message.to_community_id || message.to_skill.try(:community_id))
    return unless (membership = Membership.where(user: message.from_user_id, community: community_id).first)
    return if where(membership: membership).exists?
    return if compute_score(membership) < required_count
    create!(membership: membership)
  end

  def self.required_count
    5
  end

  def self.compute_score(membership)
    Message::Upload.in_community(membership.community).from_user(membership.user_id).count
  end

  def self.replay
    Message::Upload.find_each { |m| trigger(m) }
  end
end
