class Notification::VoteReceived < Notification
  belongs_to :vote

  Vote.after_create { Notification::VoteReceived.trigger(self) }

  def self.trigger(vote)
    return if where(vote: vote).exists?
    return unless (community = vote.message.community)
    if (membership_id = community.memberships.where(user_id: vote.message.from_user_id).ids.first)
      create!(vote: vote, to_membership_id: membership_id, created_at: vote.created_at)
    end
  end

  def self.replay
    Vote.find_each { |vote| trigger(vote) }
  end
end
