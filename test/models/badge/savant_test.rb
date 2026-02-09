require "test_helper"

class Badge::PartnerTest < ActiveSupport::TestCase
  def test_trigger
    assert_difference("Badge::Savant.count") { Skill.create!(name: "Test 1", description: "...", community: base, creator: alexis) }
    assert_no_difference("Badge::Savant.count") { Skill.create!(name: "Test 2", description: "...", community: base, creator: alexis) }
  end
end
