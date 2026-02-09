require "test_helper"

class Badge::SpecialistTest < ActiveSupport::TestCase
  def test_trigger
    Badge::Specialist.stubs(required_count: 2)
    assert_difference("Badge::Specialist.count") { subscriptions(:ror_alexis).update!(updated_at: Time.now.utc) }
    assert_no_difference("Badge::Specialist.count") { subscriptions(:ror_alexis).update!(updated_at: Time.now.utc) }
    assert_no_difference("Badge::Specialist.count") { subscriptions(:js_antoine).update!(updated_at: Time.now.utc) }
  end
end
