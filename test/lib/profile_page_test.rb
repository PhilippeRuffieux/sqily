require "test_helper"

class ProfilePageTest < ActiveSupport::TestCase
  def test_public_workspaces
    workspace = workspaces(:ror_development)
    profile = ProfilePage.new(memberships(:alexis_base))
    assert_difference("profile.public_workspaces.count") { workspace.publish! }
    assert_difference("profile.public_workspaces.count", -1) do
      HiddenProfileItem.create!(membership: profile.membership, workspace: workspace)
    end
  end

  def test_public_workspaces_when_commentator_only
    workspaces(:ror_development).publish!
    profile = ProfilePage.new(memberships(:alexis_base))
    assert_difference(-> { profile.public_workspaces.count } => -1) do
      workspace_partnerships(:ror_development_alexis).update!(read_only: true)
    end
  end

  def test_public_subscriptions
    profile = ProfilePage.new(memberships(:alexis_base))
    (subscription = subscriptions(:ror_alexis)).update!(completed_at: nil)
    assert_difference("profile.public_subscriptions.count") { subscription.touch(:completed_at) }
    assert_difference("profile.public_subscriptions.count", -1) do
      HiddenProfileItem.create!(membership: profile.membership, subscription: subscription)
    end
  end
end
