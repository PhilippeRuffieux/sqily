class DailySummaryJob < ActiveJob::Base
  queue_as :default

  attr_accessor :user

  def self.perform_now_for_all_users
    User.daily_summary.find_each do |user|
      RorVsWild.catch_error(user_id: user.id) { DailySummaryJob.perform_now(user) }
    end
  end

  def perform(user)
    @user = user
    return if user.memberships.empty?
    UserMailer.daily_summary(self).deliver_now if has_content?
  end

  def new_private_messages
    Message.find(Message.to_user(user).unread.group(:from_user_id).created_after(1.day.ago).pluck(Arel.sql("MIN(id)")))
  end

  def new_pinned_messages
    messages_reable_by_user.pinned_from(1.day.ago).where(type: [Message::Text.to_s, Message::Upload.to_s])
  end

  def new_event_messages
    messages_reable_by_user.where(type: "Message::EventCreated").created_from(1.day.ago)
  end

  def upcoming_events
    Event.joins(:participations).where("participations.user_id = ?", user).scheduled_between(1.day.from_now, 2.days.from_now)
  end

  def finished_polls
    Poll.finished_between(1.day.ago, Time.now).joins(:answers).where("poll_answers.user_id = ?", user)
  end

  def mentionned_messages
    Message::Text.text_contains(user.name).where(to_user_id: nil).created_from(1.day.ago)
  end

  def pending_homeworks
    Homework.to_approver(user).pending
  end

  def unread_notifications
    Notification.joins(:to_membership).where(memberships: {user_id: user.id}).unread.created_from(1.day.ago)
  end

  def has_content?
    new_private_messages.any? || upcoming_events.any? || unread_notifications.any?
  end

  def messages_reable_by_user
    community_ids = user.communities.pluck(:id)
    skill_ids = user.subscriptions.pluck(:skill_id)
    Message.where("to_community_id IN (?) OR to_skill_id IN (?)", community_ids, skill_ids).created_after(1.day.ago)
  end
end
