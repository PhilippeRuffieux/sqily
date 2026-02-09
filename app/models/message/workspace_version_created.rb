class Message::WorkspaceVersionCreated < Message
  belongs_to :workspace_version, class_name: "Workspace::Version"

  def self.trigger(workspace_version, from_user)
    create!(
      to_workspace_id: workspace_version.workspace_id,
      from_user: from_user,
      workspace_version_id: workspace_version.id
    )
  end
end
