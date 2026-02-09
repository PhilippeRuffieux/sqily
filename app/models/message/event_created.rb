class Message::EventCreated < Message
  belongs_to :event

  Event.after_create { Message::EventCreated.trigger(self) }

  scope :with_user_participation, ->(user_id) do
    where("(SELECT COUNT(*) FROM participations WHERE participations.event_id = messages.event_id AND participations.user_id = ?) > 0", user_id)
  end

  def self.trigger(event)
    create!(event: event, from_user_id: event.user_id, to_community_id: event.community_id, to_skill_id: event.skill_id)
  end
end
