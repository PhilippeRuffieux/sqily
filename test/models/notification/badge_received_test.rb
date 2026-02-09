require "test_helper"

class Notification::BadgeReceivedTest < ActiveSupport::TestCase
  def test_after_create_callback
    assert_difference("Notification::BadgeReceived.count") { Badge::Savant.create!(membership: Membership.first) }
    assert_no_difference("Notification::BadgeReceived.count") { Notification::BadgeReceived.trigger(Badge::Savant.last) }
  end
end
