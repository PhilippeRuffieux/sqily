class Notification::PollFinished < Notification
  belongs_to :poll

  def self.trigger_for_last_24h
    Poll.where("finished_at BETWEEN ? AND ?", 1.day.ago, Time.now).each { |poll| trigger(poll) }
  end

  def self.trigger(poll)
    return if !poll.finished?

    user_ids = poll.answers.pluck(:user_id)

    membership_ids = if poll.community
      poll.community.memberships.where(user_id: user_ids).ids
    elsif poll.skill
      poll.skill.community.memberships.where(user_id: user_ids).ids
    elsif poll.workspace
      poll.workspace.community.memberships.where(user_id: user_ids).ids
    end

    membership_ids.each do |membership_id|
      if !where(poll: poll, to_membership_id: membership_id).exists?
        create!(poll: poll, to_membership_id: membership_id, created_at: poll.finished_at)
      end
    end
  end

  def self.replay
    Poll.find_each { |poll| trigger(poll) }
  end
end
