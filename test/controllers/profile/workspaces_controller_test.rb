require "test_helper"

class Profile::WorkspacesControllerTest < ActionDispatch::IntegrationTest
  def test_show
    (workspace = workspaces(:ror_development)).publish!
    get("/base-secrete/profile/workspaces/#{workspace.id}")
    assert_response(:success)
  end
end
