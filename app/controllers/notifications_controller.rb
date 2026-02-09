class NotificationsController < ApplicationController
  before_action :must_be_membership

  def index
    @notifications = current_membership.notifications.latest.limit(25)
    @notifications = @notifications.created_before(params[:before]) if params[:before]
    current_membership.notifications.unread.update_all(read_at: Time.now)
    render(partial: "notifications/list", layout: false, locals: {notifications: @notifications}) if request.xhr?
  end
end
