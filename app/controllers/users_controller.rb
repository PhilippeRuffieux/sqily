class UsersController < ApplicationController
  before_action :find_community, only: %i[index show destroy]
  before_action :authenticate_user, only: %i[show destroy]
  before_action :must_be_moderator, only: %i[destroy]

  layout "public"

  def new
    if current_user
      redirect_user_to_most_relevant_community
    elsif params[:registration_code] && params[:community_id]
      @user = User.new
    elsif current_invitation
      @user = User.new(email: current_invitation.email)
    else
      redirect_to(root_path)
    end
  end

  def create
    if params[:registration_code].present? && params[:community_id].present?
      community = Community.find_by_id(params[:community_id])
      if community.blank? || !community.registration_code? || community.registration_code != params[:registration_code]
        @user = User.new(user_attributes)
        render(:new)
        return
      end

      if (@user = User.signup(user_attributes, current_invitation)).save
        Membership.create!(user: self.current_user = @user, community: community)
        redirect_user_to_most_relevant_community
      else
        render(:new)
      end
    elsif (@user = User.signup(user_attributes, current_invitation)).save
      self.current_invitation = nil
      self.current_user = @user
      redirect_user_to_most_relevant_community
    else
      render(:new)
    end
  end

  def sidebar
    @skill = current_community.skills.find_by_id(params[:skill_id]) if params[:skill_id]
    render(layout: false)
  end

  def index
    @skill = current_community.skills.find_by_id(params[:skill_id]) if params[:skill_id]
    render(layout: false)
  end

  def show
    @user = @community.users.find(params[:id])
    @user = User.find(params[:id])
    @membership = @user.membership_for(@community)
    @skill = current_community.skills.find_by_id(params[:skill_id])
    @subscription = @skill.subscriptions.find_by_user_id(@user.id) if @skill
    render(layout: false)
  end

  def destroy
    current_community.remove_user(User.find(params[:id]))
    redirect_to(skills_path(current_community))
  end

  def destroy_avatar
    current_user.delete_avatar
    head(:ok)
  end

  private

  def user_attributes
    params.require(:user).permit(:name, :email, :password)
  end
end
