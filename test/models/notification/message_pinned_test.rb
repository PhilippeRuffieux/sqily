require "test_helper"

class Notification::MessagePinnedTest < ActiveSupport::TestCase
  def test_trigger_when_message_is_sent_to_a_community
    message = messages(:alexis_to_base)
    assert_no_difference("Notification::MessagePinned.count") { Notification::MessagePinned.trigger(message) }
    assert_difference("Notification::MessagePinned.count", base.memberships.count - 1) { message.update!(pinned_at: Time.now) }
    assert_no_difference("Notification::MessagePinned.count") { Notification::MessagePinned.trigger(message) }
  end

  def test_trigger_when_message_is_sent_to_a_skill
    message = messages(:alexis_to_js)
    assert_no_difference("Notification::MessagePinned.count") { Notification::MessagePinned.trigger(message) }
    assert_difference("Notification::MessagePinned.count") { message.update!(pinned_at: Time.now) }
    assert_no_difference("Notification::MessagePinned.count") { Notification::MessagePinned.trigger(message) }
  end
end
