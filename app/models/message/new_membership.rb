class Message::NewMembership < Message
  Membership.after_create { Message::NewMembership.trigger(self) }

  has_and_belongs_to_many :users, foreign_key: "message_id"

  def self.trigger(membership)
    if (message = membership.community.messages.last) && message.is_a?(Message::NewMembership)
      message.users << membership.user if !message.users.exists?(membership.user_id)
    else
      create!(to_community_id: membership.community_id, users: [membership.user])
    end
  end

  def from_user_required?
    false
  end
end
