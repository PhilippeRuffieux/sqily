class Message::WorkspacePublished < Message
  belongs_to :workspace

  def self.trigger(workspace)
    create!(workspace: workspace, from_user: workspace.owner, to_community_id: workspace.skill_id ? nil : workspace.community_id, to_skill_id: workspace.skill_id)
  end

  def self.untrigger(workspace)
    where(workspace_id: workspace.id).delete_all
  end
end
