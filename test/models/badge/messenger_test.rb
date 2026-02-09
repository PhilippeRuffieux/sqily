require "test_helper"

class Badge::MessengerTest < ActiveSupport::TestCase
  def test_trigger_with_community_message
    Badge::Messenger.stubs(required_count: 4)
    assert_no_difference("Badge::Messenger.count") { Message::Text.create!(from_user: alexis, to_community: base, text: "Text") }
    assert_difference("Badge::Messenger.count") { Message::Text.create!(from_user: alexis, to_community: base, text: "Text") }
    assert_no_difference("Badge::Messenger.count") { Message::Text.create!(from_user: alexis, to_community: base, text: "Text") }
  end

  def test_trigger_with_skill_message
    Badge::Messenger.stubs(required_count: 4)
    assert_no_difference("Badge::Messenger.count") { Message::Text.create!(from_user: alexis, to_skill: ror, text: "Text") }
    assert_difference("Badge::Messenger.count") { Message::Text.create!(from_user: alexis, to_skill: ror, text: "Text") }
    assert_no_difference("Badge::Messenger.count") { Message::Text.create!(from_user: alexis, to_skill: ror, text: "Text") }
  end

  def test_trigger_with_workspace_message
    Badge::Messenger.stubs(required_count: 3)
    assert_no_difference("Badge::Messenger.count") { Message::Text.create!(from_user: alexis, to_workspace: workspaces(:ror_development), text: "Text") }
  end

  def test_trigger_with_private_message
    Badge::Messenger.stubs(required_count: 3)
    assert_no_difference("Badge::Messenger.count") { Message::Text.create!(from_user: alexis, to_user: antoine, text: "Text") }
  end
end
