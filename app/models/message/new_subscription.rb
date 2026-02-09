class Message::NewSubscription < Message
  Subscription.after_create { Message::NewSubscription.trigger(self) }

  has_and_belongs_to_many :users, foreign_key: "message_id", validate: false

  def self.trigger(subscription)
    if (message = subscription.skill.messages.last) && message.is_a?(Message::NewSubscription)
      message.users << subscription.user if !message.users.where(id: subscription.user_id).exists?
    else
      create!(to_skill_id: subscription.skill_id, users: [subscription.user])
    end
  end

  def from_user_required?
    false
  end
end
