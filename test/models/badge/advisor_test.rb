require "test_helper"

class Badge::AdvisorTest < ActiveSupport::TestCase
  def test_trigger
    workspace1 = workspaces(:ror_development)
    workspace1.partnerships.create!(user: antoine, read_only: true)
    assert_no_difference("Badge::Advisor.count") { Message::Text.create!(from_user: antoine, to_workspace: workspace1, text: "Text") }

    workspace2 = Workspace.new(community: base)
    workspace2.write_attribute(:title, "Title") # TODO: Drop column Workspace#title
    workspace2.write_attribute(:writing, "Writing") # TODO: Drop column Workspace#writing
    workspace2.save!
    workspace2.partnerships.create!(user: alexis, is_owner: true, read_only: true)
    workspace2.partnerships.create!(user: antoine, read_only: true)

    assert_difference("Badge::Advisor.count") { Message::Text.create!(from_user: antoine, to_workspace: workspace2, text: "Text") }
  end
end
