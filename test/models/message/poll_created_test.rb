require "test_helper"

class Message::PollCreatedTest < ActiveSupport::TestCase
  def test_trigger
    poll = nil
    assert_difference("Message::PollCreated.count") do
      poll = Poll.create!(user: alexis, community: base, title: "Test", finished_at: Date.tomorrow)
    end
    message = Message::PollCreated.last
    assert_equal(alexis, message.from_user)
    assert_equal(base, message.to_community)
    assert_equal(poll, message.poll)
  end
end
