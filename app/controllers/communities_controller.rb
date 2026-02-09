class CommunitiesController < ApplicationController
  include RespondMessages

  before_action :authenticate_user, except: :tree
  before_action :must_be_membership, except: :tree
  before_action :must_be_able_to_edit_community, only: [:edit, :update]

  def messages
    current_membership.touch(:last_read_at)
    @messages = filter_messages(current_community.messages.limit(25))
    @previous_page_url = messages_path(current_community, before: @messages.first.created_at.iso8601(6), after: nil, pinned: params[:pinned]) if @messages.size == 25
  end

  def update
    if current_community.update(community_params)
      redirect_to(skills_path(current_community))
    else
      render(:edit)
    end
  end

  def tree
    @user = current_community.users.find_by_id(params[:user_id]) if current_membership
    render(layout: false)
  end

  def state
    state = {
      active_user_ids: current_community.users.active.ids,
      unread_notification_count: current_membership.notifications.unread.count
    }
    render(json: state)
  end

  def duplication_form
    @community = current_community.dup
  end

  def duplicate
    if current_user.permissions.duplicate_community?(current_community)
      @community = Community::DuplicationJob.perform_now(current_community.id, current_user.id, community_params)
      if @community.persisted?
        redirect_to(skills_path(@community))
      else
        render(:duplication_form)
      end
    else
      redirect_to(skills_path(current_community))
    end
  end

  def progression
    @skills = current_community.skills.roots.published
    @users = current_community.users.order(:name).page(params[:page])
    @users = @users.by_team(current_team) if current_team
  end

  private

  def community_params
    params
      .require(:community)
      .permit(:name, :description, :permalink, :free_skill_creation, :public, :registration_code, :duplicate_evaluations)
  end

  def must_be_able_to_edit_community
    redirect_to(skills_path(current_community)) unless can_edit_current_community?
  end
end
