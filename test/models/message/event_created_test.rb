require "test_helper"

class Message::EventCreatedTest < ActiveSupport::TestCase
  def test_trigger
    event = nil
    assert_difference("Message::EventCreated.count") do
      event = Event.create!(user: alexis, community: base, title: "Test", max_participations: 5, registration_finished_at: Date.tomorrow, scheduled_at: Date.tomorrow)
    end
    message = Message::EventCreated.last
    assert_equal(alexis, message.from_user)
    assert_equal(base, message.to_community)
    assert_equal(event, message.event)
  end
end
