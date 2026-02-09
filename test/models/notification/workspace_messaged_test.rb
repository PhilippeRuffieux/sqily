require "test_helper"

class Notification::WorkspaceMessagedTest < ActiveSupport::TestCase
  def test_trigger_when_message_is_sent_to_a_workspace
    workspace = workspaces(:ror_development)
    message = Message::Text.new(from_user: antoine, text: "Test", to_workspace: workspace)
    assert_difference("Notification::WorkspaceMessaged.count", 2) { message.save! }
    assert_no_difference("Notification::WorkspaceMessaged.count") { Notification::WorkspaceMessaged.trigger(message) }
  end

  def test_trigger_when_message_is_sent_by_writer
    workspaces(:ror_development)
    message = messages(:alexis_to_workspace)
    assert_difference("Notification::WorkspaceMessaged.count", 1) { Notification::WorkspaceMessaged.trigger(message) }
  end
end
