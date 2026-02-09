require "test_helper"

class User::PermissionsTest < ActiveSupport::TestCase
  def test_evaluate_skill_when_expert
    assert(alexis.permissions.evaluate_subscription?(subscriptions(:js_antoine)))
  end

  def test_evaluate_skill_when_auto_evaluation
    skills(:js).update!(auto_evaluation: true)
    assert(antoine.permissions.evaluate_subscription?(subscriptions(:js_antoine)))
  end

  def test_evaluate_skill_when_moderator
    subscription = subscriptions(:js_antoine)
    refute(antoine.permissions.evaluate_subscription?(subscription))
    memberships(:antoine_base).update!(moderator: true)
    assert(antoine.permissions.evaluate_subscription?(subscription.reload))
  end

  def test_destroy_partnership
    alexis_partnership = workspace_partnerships(:ror_development_alexis)
    antoine_partnership = Workspace::Partnership.create!(workspace: workspaces(:ror_development), user: antoine, read_only: true)
    assert(alexis.permissions.destroy_partnership?(antoine_partnership))
    assert(antoine.permissions.destroy_partnership?(antoine_partnership))
    refute(antoine.permissions.destroy_partnership?(alexis_partnership))
  end

  def test_read_workspace
    workspace = workspaces(:ror_development)
    assert(alexis.permissions.read_workspace?(workspace))
    refute(antoine.permissions.read_workspace?(workspace))
  end

  def test_destroy_workspace
    workspace = workspaces(:ror_development)
    assert(alexis.permissions.destroy_workspace?(workspace))
    refute(antoine.permissions.destroy_workspace?(workspace))
  end

  def test_read_community_statistics
    assert(alexis.permissions.read_community_statistics?(base))
    refute(antoine.permissions.read_community_statistics?(base))
  end

  def test_downgrade_subscription?
    refute(alexis.permissions.downgrade_subscription?(subscriptions(:js_antoine)))
    subscriptions(:js_antoine).complete(alexis)
    assert(alexis.permissions.downgrade_subscription?(subscriptions(:js_antoine)))
    refute(antoine.permissions.downgrade_subscription?(subscriptions(:js_antoine)))
  end

  def test_duplicate_community
    assert(admin.permissions.duplicate_community?(hep))
    assert(admin.permissions.duplicate_community?(base))
    refute(alexis.permissions.duplicate_community?(hep))
    assert(alexis.permissions.duplicate_community?(base))
    refute(antoine.permissions.duplicate_community?(base))
  end

  def test_mark_message_as_unread
    message = messages(:alexis_to_antoine)
    assert(antoine.permissions.mark_message_as_unread?(message))
    refute(alexis.permissions.mark_message_as_unread?(message))
  end

  def test_approve_workspace
    workspace = workspaces(:ror_development)
    assert(valentin.permissions.approve_workspace?(workspace))
    refute(alexis.permissions.approve_workspace?(workspace))
    workspace.approve!
    refute(valentin.permissions.approve_workspace?(workspace))
    refute(alexis.permissions.approve_workspace?(workspace))
  end

  def test_reject_workspace
    workspace = workspaces(:ror_development)
    refute(valentin.permissions.reject_workspace?(workspace))
    refute(alexis.permissions.reject_workspace?(workspace))
    workspace.approve!
    assert(valentin.permissions.reject_workspace?(workspace))
    refute(alexis.permissions.reject_workspace?(workspace))
  end

  def test_publish_workspace
    workspace = workspaces(:ror_development)
    refute(valentin.permissions.publish_workspace?(workspace))
    refute(alexis.permissions.publish_workspace?(workspace))
    workspace.approve!
    refute(valentin.permissions.publish_workspace?(workspace))
    assert(alexis.permissions.publish_workspace?(workspace))
  end

  def test_publish_workspace_as_moderator
    memberships(:valentin_base).update!(moderator: true)
    workspace = workspaces(:ror_development)
    refute(valentin.permissions.publish_workspace?(workspace))
    workspace.approve!
    assert(valentin.permissions.publish_workspace?(workspace))
  end

  def test_unpublish_workspace
    workspace = workspaces(:ror_development)
    refute(valentin.permissions.unpublish_workspace?(workspace))
    refute(alexis.permissions.unpublish_workspace?(workspace))
    workspace.approve!
    workspace.publish!
    refute(valentin.permissions.unpublish_workspace?(workspace))
    assert(alexis.permissions.unpublish_workspace?(workspace))
  end

  def test_unpublish_workspace_as_moderator
    memberships(:valentin_base).update!(moderator: true)
    workspace = workspaces(:ror_development)
    refute(valentin.permissions.unpublish_workspace?(workspace))
    workspace.approve!
    workspace.publish!
    assert(valentin.permissions.unpublish_workspace?(workspace))
  end

  def test_administrate_workspace
    workspace = workspaces(:ror_development)
    refute(valentin.permissions.administrate_workspace?(workspace))
    memberships(:valentin_base).update!(moderator: true)
    assert(valentin.permissions.administrate_workspace?(workspace))
  end

  def test_workspace_reader
    workspace = workspaces(:ror_development)
    assert(valentin.permissions.workspace_reader?(workspace))
    workspace_partnerships(:ror_development_valentin).update!(read_only: false)
    refute(valentin.permissions.workspace_reader?(workspace))
  end

  def test_workspace_moderator
    workspace = workspaces(:ror_development)
    refute(valentin.permissions.workspace_moderator?(workspace))
    memberships(:valentin_base).update!(moderator: true)
    assert(valentin.permissions.workspace_moderator?(workspace))
  end

  def test_edit_evaluation
    evaluation = evaluations(:js)
    assert(users(:alexis).permissions.edit_evaluation?(evaluation))
    refute(users(:antoine).permissions.edit_evaluation?(evaluation))

    memberships(:antoine_base).update!(moderator: true)
    assert(users(:antoine).permissions.edit_evaluation?(evaluation))
  end
end
