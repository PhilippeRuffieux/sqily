require "test_helper"

class Badge::OmnipresentTest < ActiveSupport::TestCase
  def test_trigger
    Badge::Omnipresent.stubs(required_count: 1)
    assert_no_difference("Badge::Omnipresent.count") { Badge::Omnipresent.trigger_for_last_24h }
    js_demo.update_columns(scheduled_at: 6.hours.ago)
    assert_difference("Badge::Omnipresent.count") { Badge::Omnipresent.trigger_for_last_24h }
    assert_no_difference("Badge::Omnipresent.count") { Badge::Omnipresent.trigger_for_last_24h }
  end

  def test_trigger_when_absent
    Badge::Omnipresent.stubs(required_count: 1)
    js_demo.update_columns(scheduled_at: 6.hours.ago)
    (participation = participations(:js_demo_alexis)).update!(confirmed: false)
    assert_no_difference("Badge::Omnipresent.count") { Badge::Omnipresent.trigger_for_last_24h }
    participation.update!(confirmed: true)
    assert_difference("Badge::Omnipresent.count") { Badge::Omnipresent.trigger_for_last_24h }
    assert_no_difference("Badge::Omnipresent.count") { Badge::Omnipresent.trigger_for_last_24h }
  end
end
