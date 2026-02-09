class Public::SkillsController < ApplicationController
  layout "public"
  before_action :community_must_be_public

  def index
    @community = current_community
    render_not_found unless current_community
  end

  def show
    @community = current_community
    @skill = current_community.published_skills.find(params[:id])
  end

  private

  def community_must_be_public
    if current_community
      if !current_community.public?
        redirect_to(invitation_requests_path(current_community))
      end
    else
      render_not_found
    end
  end
end
