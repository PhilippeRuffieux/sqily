class InvitationRequestsController < ApplicationController
  before_action :must_be_moderator, only: %i[update destroy]
  before_action :must_not_be_member, only: %i[index create]
  before_action :find_invitation_request, only: %i[update destroy]

  layout "public"

  def index
    @invitation_request = InvitationRequest.new(email: current_user.try(:email))
  end

  def create
    @invitation_request = current_community.invitation_requests.new(invitation_request_attributes)
    render(:index) if !@invitation_request.save
  end

  def update
    @invitation_request.accept!
    redirect_to(invitations_path(current_community))
  end

  def destroy
    @invitation_request.destroy
    redirect_to(invitations_path(current_community))
  end

  private

  def invitation_request_attributes
    params.require(:invitation_request).permit(:email)
  end

  def find_invitation_request
    @invitation_request = current_community.invitation_requests.find(params[:id])
  end

  def must_not_be_member
    redirect_to(skills_path(current_community)) if current_membership
  end
end
