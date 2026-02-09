require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def test_between
    assert_equal(2, Message::Text.between(users(:alexis), users(:antoine)).count)
    assert_equal(2, Message::Text.between(users(:antoine), users(:alexis)).count)
  end

  def test_validate_users_are_different
    message = Message::Text.new(from_user: users(:alexis), to_user: users(:alexis), text: "Test")
    refute(message.valid?)
    assert(message.errors[:to_user].any?)
  end

  def test_validates_presence_of_a_recipient
    refute((message = Message::Text.new(from_user: users(:alexis))).valid?)
    assert(message.errors[:to_user].any?)
  end

  def test_toggle_pinned_at
    message = messages(:alexis_to_base)
    assert_difference("Message.pinned.count") { assert(message.toggle_pinned_at) }
    assert_difference("Message.pinned.count", -1) { refute(message.toggle_pinned_at) }
  end

  def test_pinnable_by
    alexis, antoine = users(:alexis), users(:antoine)

    assert(messages(:alexis_to_base).pinnable_by?(alexis))
    refute(messages(:alexis_to_base).pinnable_by?(antoine))

    assert(messages(:alexis_to_js).pinnable_by?(alexis))
    refute(messages(:alexis_to_js).pinnable_by?(antoine))

    subscriptions(:js_alexis).destroy
    assert(messages(:alexis_to_js).pinnable_by?(alexis))

    subscriptions(:js_antoine).update!(completed_at: Time.now)
    assert(messages(:alexis_to_js).pinnable_by?(antoine))
  end

  def test_toggle_deleted_at
    message = messages(:alexis_to_base)
    assert_difference("Message.not_deleted.count", -1) { message.toggle_deleted_at }
    assert_difference("Message.not_deleted.count") { message.toggle_deleted_at }
  end

  def test_latest_discussion_to
    alexis, antoine, admin = users(:alexis), users(:antoine), users(:admin)
    msg1 = messages(:antoine_to_alexis)
    assert_equal([msg1], Message.latest_discussions_to(alexis).to_a)
    msg2 = Message::Text.create!(from_user: antoine, to_user: alexis, text: "Message 2")
    assert_equal([msg2], Message.latest_discussions_to(alexis).to_a)
    msg3 = Message::Text.create!(from_user: admin, to_user: alexis, text: "Message 3")
    assert_equal([msg3, msg2], Message.latest_discussions_to(alexis).to_a)
  end

  def test_from_a_member_of
    hep = communities(:hep)
    assert_equal([], Message.from_a_member_of(hep).to_a)

    msg = Message::Text.create!(from_user: users(:admin), to_user: users(:alexis), text: "Test")
    assert_equal([msg], Message.from_a_member_of(hep).to_a)
  end

  def test_voted_by
    assert_equal(0, Message.voted_by(users(:alexis)).count)
    assert_equal(2, Message.voted_by(users(:antoine)).count)
  end

  def test_viewable_by?
    alexis, antoine, admin = users(:alexis), users(:antoine), users(:admin)
    assert(messages(:alexis_to_antoine).viewable_by?(alexis))
    assert(messages(:alexis_to_antoine).viewable_by?(antoine))
    refute(messages(:alexis_to_antoine).viewable_by?(admin))

    assert(messages(:alexis_to_base).viewable_by?(alexis))
    assert(messages(:alexis_to_base).viewable_by?(antoine))
    refute(messages(:alexis_to_base).viewable_by?(admin))

    assert(messages(:alexis_to_js).viewable_by?(alexis))
    assert(messages(:alexis_to_js).viewable_by?(antoine))
    refute(messages(:alexis_to_js).viewable_by?(admin))
  end

  def test_viewable_by_when_message_belongs_to_a_workspace
    workspace = workspaces(:ror_development)

    refute(messages(:alexis_to_workspace).viewable_by?(antoine))
    workspace.partnerships.create!(user: antoine)
    assert(messages(:alexis_to_workspace).reload.viewable_by?(antoine))

    refute(messages(:alexis_to_workspace).viewable_by?(admin))
    workspace.publish!
    assert(messages(:alexis_to_workspace).reload.viewable_by?(admin))
  end

  def test_text_search
    assert_equal(2, Message.text_search("SALUT").count)
    assert_equal(1, Message.text_search("javascript").count)
    assert_equal(1, Message.text_search("test").count)
  end

  def test_scope_with_votes
    assert_difference("Message.with_votes.count", -1) { Vote.toggle(antoine, messages(:alexis_to_base)) }
  end

  def test_can_mark_message_as_unread
    message = Message.new(read_at: Time.now)
    message.mark_as_unread
    assert_nil(message.read_at)
  end
end
