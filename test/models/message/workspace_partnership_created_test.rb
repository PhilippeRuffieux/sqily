require "test_helper"

class Message::WorkspacePartnershipCreatedTest < ActiveSupport::TestCase
  def test_trigger
    partnership = nil
    workspace = workspaces(:ror_development)
    assert_difference("Message::WorkspacePartnershipCreated.count") do
      partnership = Workspace::Partnership.create!(user: antoine, workspace: workspace)
    end
    message = Message::WorkspacePartnershipCreated.last
    assert_equal(partnership, message.workspace_partnership)
    assert_equal(alexis, message.from_user)
    assert_equal(antoine, message.to_user)
  end
end
