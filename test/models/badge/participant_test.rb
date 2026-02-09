require "test_helper"

class Badge::ParticipantTest < ActiveSupport::TestCase
  def test_trigger
    assert_difference("Badge::Participant.count") { subscriptions(:ror_alexis).update!(updated_at: Time.now.utc) }
    assert_no_difference("Badge::Participant.count") { subscriptions(:ror_alexis).update!(updated_at: Time.now.utc) }
  end
end
