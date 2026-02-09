module NotificationsHelper
  def render_notification(notification)
    path = "/notifications/#{notification.class.to_s.split("::").last.underscore}"
    render(partial: path, locals: {notification: notification}, formats: [:html])
  end

  def render_notification_for_emails(notification)
    path = "/user_mailer/notifications/#{notification.class.to_s.split("::").last.underscore}"
    render(partial: path, locals: {notification: notification}, formats: [:html])
  end

  def notifications_next_page_url(notifications)
    if (oldest = notifications.last)
      notifications_path(current_community, before: oldest.created_at)
    end
  end
end
