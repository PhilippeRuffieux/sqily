class WeeklySummaryJob < ActiveJob::Base
  queue_as :default

  attr_accessor :membership

  def self.perform_for_all_membeships
    scope = Membership.joins(:user).merge(User.where(weekly_summary: true))
    scope.find_each { |membership| perform_now(membership) }
  end

  def perform(membership)
    @membership = membership
    UserMailer.weekly_summary(self).deliver_now if has_content?
  end

  def new_community_messages
    Message::Text.to_community(membership.community).not_deleted.where("created_at > ?", 7.days.ago).latest
  end

  def new_skills
    membership.community.skills.where("created_at > ?", 1.week.ago)
  end

  def new_memberships
    membership.community.memberships.where("id != ? AND created_at > ?", membership.id, 1.week.ago)
  end

  def skills
    skill_ids = membership.community.skills.pluck(:id)
    membership.user.subscriptions.where(skill_id: skill_ids).map(&:skill)
  end

  def user
    membership.user
  end

  def has_content?
    new_community_messages.exists? || new_skills.exists? || new_memberships.exists? || unread_notifications.exists?
  end

  def pending_homeworks
    Homework.to_approver(user).pending
  end

  def unread_notifications
    membership.notifications.unread.created_from(1.week.ago)
  end

  def new_private_messages
    Message.find(Message.to_user(membership.user).unread.group(:from_user_id).created_after(1.week.ago).pluck(Arel.sql("MIN(id)")))
  end
end
