module WorkspacesHelper
  def workspace_partnerships_of(user)
    scope = user.workspace_partnerships.joins(:workspace).order("workspaces.updated_at DESC")
    scope = scope.where(workspaces: {community_id: current_community})
    (user == current_user) ? scope : scope.merge(Workspace.published).writer
  end

  def workspace_versions_options(workspace, selected = nil)
    arrays = workspace.versions.order(created_at: :desc).map { |version| [workspace_version_label(version), version.number] }
    options_for_select(arrays, selected && [workspace_version_label(selected), selected.number])
  end

  def workspace_version_label(version)
    "Version #{version.number} - #{l(version.updated_at, format: :short)}"
  end
end
