require "test_helper"

class CommunityTest < ActiveSupport::TestCase
  def test_name_writer
    refute(Community.new(name: nil).permalink)
    assert_equal("hep-vaud", Community.new(name: "HEP Vaud").permalink)
  end

  def test_name_writer_strips_whitespace
    community = Community.new(name: "  HEP Vaud  ")
    assert_equal("HEP Vaud", community.name)
  end

  def test_permalink_writer_parameterizes_value
    community = Community.new
    community.permalink = "Mon École Primaire"
    assert_equal("mon-ecole-primaire", community.permalink)
  end

  def test_permalink_writer_with_spaces
    community = Community.new
    community.permalink = "hep vaud 2024"
    assert_equal("hep-vaud-2024", community.permalink)
  end

  def test_permalink_writer_with_nil
    community = Community.new
    community.permalink = nil
    assert_nil(community.permalink)
  end

  def test_add_user
    user = users(:alexis)
    community = communities(:hep)
    assert_difference("Membership.count") do
      membership = community.add_user(user)
      assert_equal(user, membership.user)
      assert_equal(community, membership.community)
    end
  end

  def test_add_user_when_already_present
    membership, user, community = memberships(:alexis_base), users(:alexis), communities(:base)
    assert_equal(membership, community.add_user(user))
  end

  def test_add_moderator
    assert(communities(:hep).add_moderator(users(:alexis)).moderator)
  end

  def test_add_user_by_email_when_email_does_not_exist
    assert_difference("Invitation.count") { communities(:base).add_user_by_email("foo@bar.com") }
  end

  def test_add_user_by_email_when_email_exist
    assert_difference("Membership.count") { communities(:base).add_user_by_email("admin@sqily.test") }
  end

  def test_remove_user
    assert_difference("Membership.count", -1) { base.remove_user(antoine) }
  end
end
