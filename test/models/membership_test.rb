require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  def test_unread_messages
    (membership = memberships(:alexis_base)).update!(last_read_at: nil)
    assert_equal(membership.community.messages.count, membership.unread_messages.count)
    membership.update!(last_read_at: membership.community.messages.maximum(:created_at))
    assert_equal(0, membership.unread_messages.count)
  end
end
