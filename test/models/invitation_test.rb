require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  def test_find_or_create
    community = communities(:base)
    assert_difference("ActionMailer::Base.deliveries.count") do
      assert_difference("Invitation.count") { assert(Invitation.find_or_create(community, "foo@bar.com")) }
      assert_no_difference("Invitation.count") { assert(Invitation.find_or_create(community, "foo@bar.com")) }
    end
  end

  def test_find_or_create_with_invalid_email
    assert_no_difference("Invitation.count") { refute(Invitation.find_or_create(communities(:base), "invalid email")) }
  end

  def test_bulk_create
    community = communities(:base)
    assert_difference("Invitation.count", 2) do
      Invitation.bulk_create(community, %w[test1@email.com test2@email.com])
    end
  end

  def test_bulk_create_with_invalid_email
    community = communities(:base)
    assert_difference("Invitation.count", 1) do
      assert_equal(["invalid"], Invitation.bulk_create(community, %w[test1@email.com invalid]))
    end
  end

  def test_complete
    assert_difference("Invitation.count", -1) do
      assert_difference("Membership.count") { invitations(:philippe_hep).complete(users(:alexis)) }
    end
  end
end
