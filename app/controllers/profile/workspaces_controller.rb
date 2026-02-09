class Profile::WorkspacesController < ApplicationController
  layout "attestation"

  def show
    @workspace = Workspace.published.where(community: current_community, id: params[:id]).first
    render_not_found unless HiddenProfileItem.is_workspace_public?(@workspace)
  end
end
