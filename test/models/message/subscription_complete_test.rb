require "test_helper"

class Message::SubscriptionCompleteTest < ActiveSupport::TestCase
  def setup
    Homework.any_instance.stubs(:save_file)
  end

  def test_callback
    subscriptions(:js_antoine)
    assert_emails(1) do
      assert_difference("Message::SubscriptionComplete.count") do
        homeworks(:js_antoine).approve(users(:alexis))
      end
    end
    assert_equal(homeworks(:js_antoine), Message::SubscriptionComplete.last.homework)
  end

  def test_callback_when_self_validated
    assert_no_emails do
      assert_difference("Message::SubscriptionComplete.count") do
        subscriptions(:js_antoine).complete(users(:antoine))
      end
    end
  end
end
