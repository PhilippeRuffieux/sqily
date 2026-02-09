require "test_helper"

class Workspaces::PartnershipsControllerTest < ActionController::TestCase
  def test_create
    login(alexis)
    workspace = workspaces(:ror_development)
    assert_difference("Workspace::Partnership.count") do
      post(:create, params: {permalink: base, workspace_id: workspace.id, workspace_partnership: {user_id: antoine.id, read_only: true}})
      assert_redirected_to(edit_workspace_path(base, workspace))
    end
  end

  def test_destroy
    login(alexis)
    workspace = workspaces(:ror_development)
    partnership = workspace.partnerships.create!(user: antoine)
    assert_difference("Workspace::Partnership.count", -1) do
      delete(:destroy, params: {permalink: base, workspace_id: workspace.id, id: partnership.id})
      assert_redirected_to(edit_workspace_path(base, workspace))
    end
  end

  def test_destroy_self
    login(antoine)
    workspace = workspaces(:ror_development)
    partnership = workspace.partnerships.create!(user: antoine)
    assert_difference("Workspace::Partnership.count", -1) do
      delete(:destroy, params: {permalink: base, workspace_id: workspace.id, id: partnership.id})
      assert_redirected_to(skills_path(base))
    end
  end
end
