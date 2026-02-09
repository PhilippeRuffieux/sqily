require "test_helper"

class WorkspacesControllerTest < ActionController::TestCase
  def test_create
    login(alexis)
    assert_difference("Workspace.count") do
      post(:create, params: {permalink: base})
    end
    assert_redirected_to("/#{base.permalink}/workspaces/#{Workspace.last.id}/edit")
  end

  def test_show_private_when_owner
    login(alexis)
    get(:show, params: {permalink: base, id: workspaces(:ror_development).id})
    assert_response(:success)
  end

  def test_show_private_when_not_collaborator
    login(antoine)
    workspace = workspaces(:ror_development)
    assert_raise(ActiveRecord::RecordNotFound) do
      get(:show, params: {permalink: base, id: workspace.id})
    end
  end

  def test_show_when_published
    login(antoine)
    (workspace = workspaces(:ror_development)).publish!
    get(:show, params: {permalink: base, id: workspace.id})
    assert_response(:success)
  end

  def test_edit
    login(alexis)
    workspace = workspaces(:ror_development)
    get(:edit, params: {permalink: base, id: workspace.id})
    assert_response(:success)
  end

  def test_update
    login(alexis)
    workspace = workspaces(:ror_development)
    patch(:update, params: {permalink: base, id: workspace.id, workspace: {title: "New title"}})
    assert_response(:success)
    assert_equal("New title", workspace.reload.title)
  end

  def test_publish
    login(alexis)
    workspace = workspaces(:ror_development)
    workspace.approve!
    patch(:publish, params: {permalink: base, id: workspace.id})
    assert_redirected_to("/#{base.permalink}/workspaces/#{workspace.id}")
    assert(workspace.reload.published_at)
  end

  def test_publish_with_unapproved_workspace
    login(alexis)
    workspace = workspaces(:ror_development)
    workspace.reject!
    patch(:publish, params: {permalink: base, id: workspace.id})
    assert_redirected_to("/#{base.permalink}/workspaces/#{workspace.id}")
    refute(workspace.reload.published_at)
  end

  def test_publish_to_skill
    login(alexis)
    workspace = workspaces(:ror_development)
    workspace.approve!
    patch(:publish, params: {permalink: base, id: workspace.id, skill_id: ror.id})
    assert_redirected_to("/#{base.permalink}/workspaces/#{workspace.id}")
    assert(workspace.reload.published_at)
    assert_equal(ror, workspace.skill)
  end

  def test_unpublish
    login(valentin)
    workspace = workspaces(:ror_development)
    workspace.approve!
    login(alexis)
    workspace.publish!
    post(:unpublish, params: {permalink: base, id: workspace.id})
    assert_redirected_to("/#{base.permalink}/workspaces/#{workspace.id}")
    refute(workspace.reload.published_at)
  end

  def test_unpublish_with_unapproved_workspace
    login(valentin)
    workspace = workspaces(:ror_development)
    workspace.reject!
    login(alexis)
    workspace = workspaces(:ror_development)
    post(:unpublish, params: {permalink: base, id: workspace.id})
    assert_redirected_to("/#{base.permalink}/workspaces/#{workspace.id}")
    refute(workspace.reload.published_at)
  end

  def test_approve
    login(valentin)
    workspace = workspaces(:ror_development)
    patch(:approve, params: {permalink: base, id: workspace.id})
    assert_redirected_to("/#{base.permalink}/workspaces/#{workspace.id}")
    assert(workspace.reload.approved_at)
  end

  def test_unauthorized_approve
    login(alexis)
    workspace = workspaces(:ror_development)
    patch(:approve, params: {permalink: base, id: workspace.id})
    assert_redirected_to("/#{base.permalink}/workspaces/#{workspace.id}")
    refute(workspace.reload.approved_at)
  end

  def test_reject
    login(valentin)
    workspace = workspaces(:ror_development)
    workspace.approve!
    patch(:reject, params: {permalink: base, id: workspace.id})
    assert_redirected_to("/#{base.permalink}/workspaces/#{workspace.id}")
    refute(workspace.reload.approved_at)
  end

  def test_unauthorized_reject
    login(valentin)
    workspace = workspaces(:ror_development)
    workspace.approve!
    login(alexis)
    patch(:reject, params: {permalink: base, id: workspace.id})
    assert_redirected_to("/#{base.permalink}/workspaces/#{workspace.id}")
    assert(workspace.reload.approved_at)
  end

  def test_destroy
    login(alexis)
    assert_difference("Workspace.count", -1) do
      delete(:destroy, params: {permalink: base, id: workspaces(:ror_development).id})
      assert_redirected_to(skills_path(base))
    end
  end

  def test_edit_trigger_new_version_if_message_not_from_author
    login(alexis)
    workspace = workspaces(:ror_development)
    change_request = messages(:antoine_to_workspace)
    change_request.created_at = workspace.last_version.created_at.advance(days: 1)
    change_request.save!
    assert_difference("workspace.versions.count") do
      get(:edit, params: {permalink: base, id: workspace.id})
    end
  end

  def test_edit_does_not_trigger_new_version_if_message_from_author
    login(alexis)
    workspace = workspaces(:ror_development)
    change_request = messages(:antoine_to_workspace)
    change_request.created_at = workspace.last_version.created_at.advance(days: 1)
    change_request.save!
    assert_difference("workspace.versions.count") do
      get(:edit, params: {permalink: base, id: workspace.id})
    end
  end
end
