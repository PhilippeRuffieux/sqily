class Message::WorkspacePartnershipCreated < Message
  belongs_to :workspace_partnership, class_name: "Workspace::Partnership"

  Workspace::Partnership.after_create { Message::WorkspacePartnershipCreated.trigger(self) }

  def self.trigger(partnership)
    return if partnership.is_owner
    create!(workspace_partnership: partnership, from_user_id: partnership.workspace.owner.id, to_user_id: partnership.user_id)
  end
end
