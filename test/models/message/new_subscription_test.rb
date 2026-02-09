require "test_helper"

class Message::NewSubscriptionTest < ActiveSupport::TestCase
  def test_callback
    html.unsubscribe(antoine)
    assert_difference("Message::NewSubscription.count") { Subscription.create!(user: users(:alexis), skill: html) }
    assert_no_difference("Message::NewSubscription.count") { Subscription.create!(user: users(:antoine), skill: html) }
    assert_equal(2, html.messages.last.users.count)
  end
end
