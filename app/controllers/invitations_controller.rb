class InvitationsController < ApplicationController
  before_action :find_community
  before_action :find_invitation, only: %i[show destroy]
  before_action :must_be_moderator, only: %i[index create destroy]

  def index
    @invitations = @community.invitations
    @invitation_requests = @community.invitation_requests
  end

  def create
    @invalid_emails = Invitation.bulk_create(@community, params[:invitation][:email].split("\n"))
    if @invalid_emails.empty?
      redirect_to(invitations_path(permalink: @community.permalink))
    else
      index
      render(:index)
    end
  end

  def show
    if current_user
      @invitation.complete(current_user)
      redirect_to(skills_path(@community))
    else
      self.current_invitation = @invitation
      redirect_to(new_user_path)
    end
  end

  def destroy
    @invitation.destroy
    redirect_to(invitations_path(permalink: @community.permalink))
  end

  private

  def find_invitation
    @invitation = current_community.invitations.find_by_token(params[:token]) or render_not_found
  end
end
