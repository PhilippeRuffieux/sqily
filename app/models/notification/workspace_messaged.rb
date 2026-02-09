class Notification::WorkspaceMessaged < Notification
  belongs_to :message

  Message::Text.after_save { Notification::WorkspaceMessaged.trigger(self) }

  def self.trigger(message)
    return if !message.to_workspace_id
    message.to_workspace.users.where.not(id: message.from_user_id).each do |writer|
      if (membership = Membership.where(user: writer, community_id: message.to_workspace.community_id).first)
        if where(to_membership: membership, message: message).empty?
          create!(to_membership: membership, message: message, created_at: message.created_at)
        end
      end
    end
  end

  def self.replay
    Message.where.not(to_workspace_id: nil).find_each { |msg| trigger(msg) }
  end
end
