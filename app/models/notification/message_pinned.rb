class Notification::MessagePinned < Notification
  belongs_to :message

  Message.after_save { Notification::MessagePinned.trigger(self) }

  def self.trigger(message)
    return if !message.pinned_at || where(message: message).exists?
    if message.to_community
      membership_id = message.to_community.memberships.where(user_id: message.from_user_id).ids.first
      (message.to_community.memberships.ids - [membership_id]).each do |membership_id|
        create!(message: message, to_membership_id: membership_id, created_at: message.pinned_at)
      end
    elsif message.to_skill
      (message.to_skill.subscriptions.pluck(:user_id) - [message.from_user_id]).each do |user_id|
        if (membership_id = message.to_skill.community.memberships.where(user_id: user_id).ids.first)
          create!(message: message, to_membership_id: membership_id, created_at: message.pinned_at)
        end
      end
    end
  end

  def self.replay
    Message.pinned.find_each { |msg| trigger(msg) }
  end
end
