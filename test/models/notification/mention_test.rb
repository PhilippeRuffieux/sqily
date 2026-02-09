require "test_helper"

class Notification::MentionTest < ActiveSupport::TestCase
  def test_after_create_callback
    message = messages(:alexis_to_base)
    assert_no_difference("Notification::Mention.count") { Notification::Mention.trigger(message) }
    assert_difference("Notification::Mention.count") { message.update!(text: "Hello @Antoine !") }
    assert_no_difference("Notification::Mention.count") { Notification::Mention.trigger(message) }
  end

  def test_trigger_when_user_name_contains_spaces
    message = messages(:alexis_to_base)
    antoine.update!(name: "Antoine Marguerie")
    assert_difference("Notification::Mention.count") { message.update!(text: "Hello @Antoine Marguerie !") }
    assert_no_difference("Notification::Mention.count") { Notification::Mention.trigger(message) }
  end

  def test_trigger_when_user_name_is_not_in_the_community
    assert_no_difference("Notification::Mention.count") { messages(:alexis_to_base).update!(text: "Hello @Admin !") }
  end
end
