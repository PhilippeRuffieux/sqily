require "test_helper"

class WorkspaceTest < ActiveSupport::TestCase
  def test_owner
    assert_equal(alexis, workspaces(:ror_development).owner)
  end

  def test_writers
    assert_equal([alexis], workspaces(:ror_development).writers)
  end

  def test_publish
    workspace = workspaces(:ror_development)
    assert_difference("Message::WorkspacePublished.count") do
      workspace.publish!
      assert(workspace.published_at)
    end
    assert_equal(base, Message::WorkspacePublished.last.to_community)
    refute(Message::WorkspacePublished.last.to_skill)
  end

  def test_publish_to_skill
    workspace = workspaces(:ror_development)
    assert_difference("Message::WorkspacePublished.count") do
      workspace.publish!(ror)
      assert(workspace.published_at)
      assert_equal(ror, workspace.skill)
    end
    assert_equal(ror, Message::WorkspacePublished.last.to_skill)
    refute(Message::WorkspacePublished.last.to_community)
  end

  def test_unpublish
    (workspace = workspaces(:ror_development)).publish!
    assert_difference("Message::WorkspacePublished.count", -1) do
      workspace.unpublish!
      refute(workspace.published_at)
    end
  end

  def test_approve
    (workspace = workspaces(:ror_development)).approve!
    assert(workspace.approved_at)
  end

  def test_reject
    workspace = workspaces(:ror_development)
    workspace.approve!
    workspace.reject!
    refute(workspace.approved_at)
    workspace.approve!
    workspace.publish!
    workspace.unpublish!
    workspace.reject!
    assert(workspace.approved_at)
  end

  def test_rejectable?
    workspace = workspaces(:ror_development)
    workspace.approve!
    assert(workspace.rejectable?)
    workspace.publish!
    refute(workspace.rejectable?)
    workspace.unpublish!
    refute(workspace.rejectable?)
  end

  def test_new_version
    version = workspaces(:ror_development).new_version({title: "Title", writing: "Writing"})
    assert_equal("Writing", version.writing)
    assert_equal("Title", version.title)
    assert_equal(2, version.number)
  end

  def test_require_new_version_if_messages_not_from_author
    workspace = workspaces(:ror_development)
    change_request = messages(:antoine_to_workspace)
    change_request.created_at = workspace.last_version.created_at.advance(days: 1)
    change_request.save!
    assert(workspace.requires_new_version?)
  end

  def test_does_not_require_new_version_if_messages_from_author
    workspace = workspaces(:ror_development)
    change_request = messages(:alexis_to_workspace)
    change_request.created_at = workspace.last_version.created_at.advance(days: 1)
    change_request.save!
    refute(workspace.requires_new_version?)
  end

  def test_does_not_create_new_version_if_message_not_from_author
    login(alexis)
    workspace = workspaces(:ror_development)
    change_request = messages(:antoine_to_workspace)
    change_request.created_at = workspace.last_version.created_at.advance(days: 1)
    change_request.save!
    assert_difference("workspace.versions.count") do
      workspace.last_or_new_version
    end
  end

  def test_create_new_version_if_message_from_author
    workspace = workspaces(:ror_development)
    change_request = messages(:antoine_to_workspace)
    change_request.created_at = workspace.last_version.created_at.advance(days: 1)
    change_request.save!
    assert_difference("workspace.versions.count") do
      workspace.last_or_new_version
    end
  end
end
