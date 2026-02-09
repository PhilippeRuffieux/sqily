class MembershipsController < ApplicationController
  before_action :find_community

  def show
  end

  def update
    if current_membership.update(membership_attributes) && current_user.update(user_attributes)
      redirect_to(skills_path(current_community))
    else
      render(:show)
    end
  end

  def moderator
    membership = @community.memberships.find(params[:id])
    membership.toggle!(:moderator)
    redirect_to(skills_path(@community))
  end

  def create
    if current_community.registration_code.blank?
      redirect_to(invitation_requests_path(current_community), notice: I18n.t("communities.registration_code_disabled"))
      return
    end

    if current_community.registration_code != params[:registration_code]
      redirect_to(invitation_requests_path(current_community), notice: I18n.t("communities.invalid_registration_code"))
      return
    end

    if current_user.nil?
      redirect_to(new_user_path(registration_code: params[:registration_code], community_id: current_community.id))
      return
    end

    if current_user.membership_for(current_community)
      redirect_to(skills_path(current_community), notice: I18n.t("communities.already_member"))
      return
    end

    Membership.create!(user: current_user, community: current_community)
    redirect_to(skills_path(current_community))
  end

  private

  def membership_attributes
    params.require(:membership).permit(:description)
  end

  def user_attributes
    params.require(:user).permit(:name, :email, :password, :avatar, :locale, :daily_summary, :weekly_summary)
  end
end
