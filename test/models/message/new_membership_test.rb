require "test_helper"

class Message::NewMembershipTest < ActiveSupport::TestCase
  def test_callback
    community = communities(:hep)
    assert_difference("Message::NewMembership.count") { community.add_user(users(:alexis)) }
    msg = Message::NewMembership.last
    assert_equal([alexis.id], msg.user_ids)

    assert_no_difference("Message::NewMembership.count") { community.add_user(users(:antoine)) }
    assert_equal([alexis.id, antoine.id].sort, msg.reload.user_ids.sort)

    assert_no_difference("Message::NewMembership.count") { Message::NewMembership.trigger(Membership.last) }
    assert_equal([alexis.id, antoine.id].sort, msg.reload.user_ids.sort)
  end
end
