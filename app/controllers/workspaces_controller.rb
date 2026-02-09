class WorkspacesController < ApplicationController
  include RespondMessages

  before_action :authenticate_user
  before_action :must_be_membership
  before_action :find_workspace, only: [:show, :edit, :update, :approve, :reject, :publish, :unpublish]
  before_action :find_owned_workspace, only: [:destroy]

  def create
    form = WorkspaceForm.create(community: current_community, owner: current_user)
    redirect_to(edit_workspace_path(current_community, form.workspace))
  end

  def show
    @partnership = @workspace.partnerships.find_by_user_id(current_user.id)
    @messages = filter_messages(@workspace.messages).latest
    @partnership&.touch(:read_at)
    @version = params[:version] ? @workspace.versions.find_by_number(params[:version]) : @workspace.last_version
  end

  def edit
    unless current_user.permissions.update_workspace?(@workspace)
      redirect_to(workspace_path(current_community, @workspace), alert: t("lib.unauthorized"))
    end

    if Workspace::Lock.take(@workspace, current_user)
      @version = @workspace.last_or_new_version do |new_version|
        Message::WorkspaceVersionCreated.trigger(new_version, current_user)
      end
      render(:edit)
    else
      lock = Workspace::Lock.last_active(@workspace)
      redirect_to(workspace_path(current_community, @workspace), alert: t("workspaces.edit.locked_alert", user: lock.user.name))
    end
  end

  def update
    if Workspace::Lock.take(@workspace, current_user)
      @workspace.last_version.update!(workspace_params)
      @workspace.partnerships.where(user: current_user).first.touch(:read_at)
      head(:ok)
    else
      head(:locked)
    end
  end

  def publish
    unless current_user.permissions.publish_workspace?(@workspace)
      redirect_to(workspace_path(current_community, @workspace), alert: t("lib.unauthorized"))
      return
    end

    if current_user.permissions.administrate_workspace?(@workspace)
      @workspace.approve!
      Message::WorkspaceApprovedInternal.trigger(@workspace, current_user)
    end

    skill = current_user.skills.in_community(current_community).merge(Subscription.completed).find_by_id(params[:skill_id])
    @workspace.publish!(skill)
    Message::WorkspacePublishedInternal.trigger(@workspace, current_user)
    redirect_to(workspace_path(current_community, @workspace))
  end

  def unpublish
    unless current_user.permissions.unpublish_workspace?(@workspace)
      redirect_to(workspace_path(current_community, @workspace), alert: t("lib.unauthorized"))
      return
    end

    @workspace.unpublish!
    Message::WorkspaceUnpublishedInternal.trigger(@workspace, current_user)
    redirect_to(workspace_path(current_community, @workspace))
  end

  def approve
    unless current_user.permissions.approve_workspace?(@workspace)
      redirect_to(workspace_path(current_community, @workspace), alert: t("lib.unauthorized"))
      return
    end

    @workspace.approve!
    Message::WorkspaceApprovedInternal.trigger(@workspace, current_user)
    redirect_to(workspace_path(current_community, @workspace))
  end

  def reject
    unless current_user.permissions.reject_workspace?(@workspace)
      redirect_to(workspace_path(current_community, @workspace), alert: t("lib.unauthorized"))
      return
    end

    @workspace.reject!
    Message::WorkspaceRejectedInternal.trigger(@workspace, current_user)
    redirect_to(workspace_path(current_community, @workspace))
  end

  def destroy
    @workspace.destroy
    redirect_to(skills_path(current_community))
  end

  private

  def find_workspace
    @workspace = current_user.workspaces.find_by_id(params[:id]) ||
      Workspace.published.find_by!(community: current_community, id: params[:id])
  end

  def find_owned_workspace
    @workspace = current_user.owned_workspaces.find(params[:workspace_id] || params[:id])
  end

  def workspace_params
    params.require(:workspace).permit(:title, :writing)
  end
end
