class Workspaces::PartnershipsController < ApplicationController
  before_action :find_workspace

  def create
    @workspace.partnerships.create!(workspace_partnership_params)
    redirect_back(fallback_location: edit_workspace_path(current_community, @workspace))
  end

  def destroy
    partnership = @workspace.partnerships.find(params[:id])
    partnership.destroy if current_user.permissions.destroy_partnership?(partnership)
    if current_user.permissions.update_workspace?(@workspace)
      redirect_to(edit_workspace_path(current_community, @workspace))
    else
      redirect_to(skills_path(current_community))
    end
  end

  private

  def workspace_partnership_params
    params.require(:workspace_partnership).permit(:user_id, :read_only)
  end

  def find_workspace
    @workspace = current_user.workspaces.find(params[:workspace_id] || params[:id])
  end
end
