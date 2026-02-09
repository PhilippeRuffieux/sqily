require "test_helper"

class Badge::PartnerTest < ActiveSupport::TestCase
  def test_trigger
    Badge::Partner.stubs(required_count: 4)
    assert_no_difference("Badge::Partner.count") { Vote.create!(message: messages(:js_demo_event), user: antoine) }
    assert_difference("Badge::Partner.count") { Vote.create!(message: messages(:alexis_file_to_ror), user: antoine) }
    assert_no_difference("Badge::Partner.count") { Vote.create!(message: messages(:alexis_to_workspace), user: antoine) }
  end
end
