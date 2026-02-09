class EventReminderNotificationJob < ActiveJob::Base
  queue_as :default

  def perform
    Event.scheduled_between(Date.tomorrow, Date.tomorrow.tomorrow).find_each do |event|
      event.users.each do |user|
        UserMailer.event_reminder(event, user).deliver_now
      end
    end
  end
end
