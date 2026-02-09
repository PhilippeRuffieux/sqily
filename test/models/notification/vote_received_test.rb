require "test_helper"

class Notification::VoteReceivedTest < ActiveSupport::TestCase
  def test_after_create_callback
    assert_difference("Notification::VoteReceived.count") { Vote.create!(message: messages(:alexis_to_base), user: admin) }
    assert_no_difference("Notification::VoteReceived.count") { Notification::VoteReceived.trigger(Vote.last) }
  end

  def test_trigger_does_not_create_notifications_for_private_messages
    assert_no_difference("Notification::VoteReceived.count") { Vote.create!(message: messages(:alexis_to_antoine), user: antoine) }
  end
end
