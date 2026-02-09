require "test_helper"

class BadgeTest < ActiveSupport::TestCase
  def test_send_email_notification_after_create
    skip
    assert_emails(1) { Badge::Specialist.create!(membership: memberships(:alexis_base)) }
  end

  def test_replay
    old_count = Badge.count
    Badge.replay
    assert(Badge.count > old_count)
  end
end
