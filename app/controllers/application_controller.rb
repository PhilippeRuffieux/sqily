require "inline_error_form_builder"

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CurrentUser
  include CurrentInvitation
  include PermissionsHelper
  include PageViewLogger
  include ReturnUrl

  before_action :set_current_user_locale
  before_action :prevent_browser_from_caching

  private

  def current_community
    @current_community ||= Community.find_by_permalink(params[:permalink])
  end

  helper_method :current_community

  def current_membership
    @current_membership ||= current_community && current_user&.membership_for(current_community)
  end

  helper_method :current_membership

  def current_team
    return @current_team if defined?(@current_team)
    @current_team = (current_team_id.to_i > 0) ? current_community.teams.find_by_id(current_team_id) : nil
  end

  helper_method :current_team

  def current_team_id
    return @current_team_id if defined?(@current_team_id)
    team_id ||= params[:team_id].presence || (session[:current_team_ids] ||= {})[current_community.id.to_s] || current_membership.team_id
    team_id = (@current_team_id = Integer(team_id, exception: false) || "*") # Wildcard for all teams
    (session[:current_team_ids] ||= {})[current_community.id] = team_id
  end

  helper_method :current_team_id

  def find_community
    if (@community = Community.find_by_permalink(params[:permalink]))
      session[:latest_community_id] = @community.id
    else
      render_not_found
    end
  end

  def render_not_found
    render(file: Rails.root.join("public/404.html"), layout: false, status: :not_found)
  end

  def redirect_user_to_most_relevant_community
    if current_user
      if current_user.communities.any?
        redirect_to(skills_path(current_user_last_active_community || current_user.communities.first))
      else
        redirect_to("/", notice: "Vous n'êtes inscrit à aucune communauté.")
      end
    end
  end

  def current_user_last_active_community
    current_user.communities.find_by_id(session[:latest_community_id])
  end

  def authenticate_user
    if !current_user
      current_community ? redirect_to(invitation_requests_path(current_community)) : redirect_to(session_path)
    else
      current_user.touch_last_activity_at
    end
  end

  def moderator?
    current_membership&.moderator
  end

  helper_method :moderator?

  def admin?
    current_user&.admin?
  end

  helper_method :admin?

  def must_be_moderator
    if !moderator?
      current_community ? redirect_to(skills_path(current_community)) : redirect_to("/")
    end
  end

  def must_be_membership
    if current_community
      if !current_membership
        request.xhr? ? head(:not_found) : redirect_to(invitation_requests_path(current_community))
      end
    else
      render_not_found
    end
  end

  def prevent_browser_from_caching
    # More info here: https://stackoverflow.com/questions/45329731/csrf-tokens-to-not-match-what-is-in-session-rails-4-1#45683428
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
    response.headers["Pragma"] = "no-cache"
  end
end
