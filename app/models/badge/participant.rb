# TODO: Renommer en Initiated
class Badge::Participant < Badge
  Subscription.after_update { Badge::Participant.trigger(self) }

  def self.trigger(subscription)
    return if !subscription.completed_at
    return unless (membership = Membership.where(user: subscription.user_id, community: subscription.skill.community_id).first)
    return if where(membership: membership).exists?
    create!(membership: membership)
  end

  def self.required_count
    1
  end

  def self.compute_score(membership)
    membership.user.subscriptions.joins(:skill).where(skills: {community_id: membership.community_id}).completed.count
  end

  def self.replay
    Subscription.find_each { |s| trigger(s) }
  end
end
