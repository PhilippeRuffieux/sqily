require "test_helper"

class UserTest < ActiveSupport::TestCase
  def test_signup
    assert_difference("Membership.count") do
      assert_difference("User.count") do
        User.signup({name: "John", email: "john@smith.com", password: "password"}, invitations(:philippe_hep))
      end
    end
  end

  def test_order_by_last_message
    _, antoine, admin = users(:alexis), users(:antoine), users(:admin)
    assert_equal("Alexis", User.order_by_last_message(admin).first.name)
    assert_equal("Alexis", User.order_by_last_message(antoine).first.name)
    Message::Text.create!(from_user: antoine, to_user: admin, text: "Test")
    assert_equal(%w[Antoine Alexis], User.order_by_last_message(admin).pluck(:name)[0..1])
  end

  def test_with_unread_messages_to
    _, _, admin = users(:alexis), users(:antoine), users(:admin)
    assert_equal(["Alexis"], User.with_unread_messages_to(admin).pluck(:name))
  end

  def test_update_last_activity
    (user = users(:alexis)).touch_last_activity_at
    assert(user.last_activity_at)
  end

  def test_order_by_skill_ranking
    js = skills(:js)
    msg1 = messages(:alexis_to_js)
    alexis, antoine = users(:alexis), users(:antoine)
    subscriptions(:js_antoine).touch(:completed_at)
    Vote.delete_all

    assert_equal(%w[Alexis Antoine], js.experts.order_by_skill_ranking(js).pluck(:name))

    msg2 = Message::Text.create!(from_user: antoine, to_skill: js, text: "test")
    Message::Text.create!(from_user: antoine, to_skill: js, text: "test")
    Message::Text.create!(from_user: antoine, to_skill: js, text: "test")
    assert_equal(%w[Antoine Alexis], js.experts.order_by_skill_ranking(js).pluck(:name))

    msg1.touch(:pinned_at)
    assert_equal(%w[Alexis Antoine], js.experts.order_by_skill_ranking(js).pluck(:name))

    Vote.create!(user: alexis, message: msg2)
    assert_equal(%w[Antoine Alexis], js.experts.order_by_skill_ranking(js).pluck(:name))
  end

  def test_order_by_community_ranking
    community = communities(:base)
    msg1 = messages(:alexis_to_base)
    _, antoine = users(:alexis), users(:antoine)
    Vote.delete_all

    assert_equal(%w[Alexis Antoine Valentin], community.users.order_by_community_ranking(community).pluck(:name))

    Message::Text.create!(from_user: antoine, to_community: community, text: "test", pinned_at: Time.now)
    assert_equal(%w[Antoine Alexis Valentin], community.users.order_by_community_ranking(community).pluck(:name))

    Vote.create!(user: antoine, message: msg1)
    assert_equal(%w[Alexis Antoine Valentin], community.users.order_by_community_ranking(community).pluck(:name))
  end
end
