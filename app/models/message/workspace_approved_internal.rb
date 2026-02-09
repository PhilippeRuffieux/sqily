class Message::WorkspaceApprovedInternal < Message
  def self.trigger(workspace, from_user)
    create!(
      to_workspace_id: workspace.id,
      from_user: from_user
    )
  end
end
