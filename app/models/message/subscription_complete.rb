class Message::SubscriptionComplete < Message
  belongs_to :homework, optional: true

  Subscription.after_update { Message::SubscriptionComplete.trigger(self) }

  after_create { send_email }

  def self.trigger(subscription)
    return if !subscription.completed_at
    attributes = {from_user_id: subscription.user_id, to_skill_id: subscription.skill_id}
    where(attributes).first || create!(attributes.merge(homework: subscription.homeworks.approved.first))
  end

  def subscription
    Subscription.where(user_id: from_user_id, skill_id: to_skill_id).first
  end

  def send_email
    if subscription.user_id != subscription.validator_id && subscription.skill.creator_id != subscription.user_id
      UserMailer.subscription_complete(subscription).deliver_now
    end
  end
end
