class Message::PollCreated < Message
  belongs_to :poll

  Poll.after_create { Message::PollCreated.trigger(self) }

  def self.trigger(poll)
    create!(poll: poll, from_user_id: poll.user_id, to_community_id: poll.community_id, to_skill_id: poll.skill_id, to_workspace_id: poll.workspace_id)
  end
end
