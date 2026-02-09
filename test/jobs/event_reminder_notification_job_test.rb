require "test_helper"

class EventReminderNotificationJobTest < ActiveJob::TestCase
  def test_when_there_is_no_event_tomorrow
    assert_emails(0) { EventReminderNotificationJob.perform_now }
  end

  def test_when_there_is_an_event_tomorrow
    js_demo.update!(registration_finished_at: Date.today, scheduled_at: 1.day.from_now)
    assert_emails(1) { EventReminderNotificationJob.perform_now }
  end
end
