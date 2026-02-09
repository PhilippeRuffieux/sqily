class Vote < ActiveRecord::Base
  belongs_to :message
  belongs_to :user

  validates_presence_of :message_id, :user_id

  scope :from_user, ->(user) { where(user_id: user.id) }
  scope :to_user, ->(user) { joins(:message).where(messages: {from_user_id: user}) }
  scope :in_community, ->(community) { joins(:message).merge(Message.in_community(community).not_deleted) }
  scope :in_skill, ->(skill) { joins(:message).merge(Message.to_skill(skill).not_deleted) }

  def self.toggle(user, message)
    if (vote = Vote.where(user_id: user.id, message_id: message.id).first)
      vote.destroy
    else
      Vote.create!(user: user, message: message)
    end
  rescue ActiveRecord::RecordNotUnique
  end
end
