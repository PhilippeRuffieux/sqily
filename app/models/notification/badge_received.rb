class Notification::BadgeReceived < Notification
  belongs_to :badge

  Badge.after_create { Notification::BadgeReceived.trigger(self) }

  def self.trigger(badge)
    return if where(badge: badge).exists?
    create!(badge: badge, to_membership_id: badge.membership_id, created_at: badge.created_at)
  end

  def self.replay
    Badge.find_each { |badge| trigger(badge) }
  end
end
