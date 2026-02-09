require "test_helper"

class VoteTest < ActiveSupport::TestCase
  def test_toggle
    user, message = users(:alexis), messages(:alexis_created_ror)
    assert_difference("Vote.count") { Vote.toggle(user, message) }
    assert_difference("Vote.count", -1) { Vote.toggle(user, message) }
  end

  def test_to_user
    assert_difference("Vote.to_user(users(:alexis)).count") do
      Vote.toggle(users(:antoine), messages(:alexis_created_ror))
    end
  end

  def test_in_community
    assert_equal(0, Vote.in_community(communities(:hep)).count)
    assert_equal(2, Vote.in_community(communities(:base)).count)
  end

  def test_in_skill
    assert_equal(0, Vote.in_skill(skills(:ror)).count)
    assert_equal(1, Vote.in_skill(skills(:js)).count)
  end
end
