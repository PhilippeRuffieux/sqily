require "test_helper"

class Profile::HiddenItemsControllerTest < ActionDispatch::IntegrationTest
  def test_create_with_workspace
    login(alexis)
    subscription = subscriptions(:ror_alexis)
    assert_difference("HiddenProfileItem.count") do
      post("/base-secrete/profile/hidden_items", params: {hidden_profile_item: {subscription_id: subscription.id}})
      assert_redirected_to("/base-secrete/profile/#{memberships(:alexis_base).id}")
    end
    assert_equal(subscription, HiddenProfileItem.last.subscription)
  end

  def test_create_with_subscription
    login(alexis)
    workspace = workspaces(:ror_development)
    assert_difference("HiddenProfileItem.count") do
      post("/base-secrete/profile/hidden_items", params: {hidden_profile_item: {workspace_id: workspace.id}})
      assert_redirected_to("/base-secrete/profile/#{memberships(:alexis_base).id}")
    end
    assert_equal(workspace, HiddenProfileItem.last.workspace)
  end

  def test_destroy
    hidden_item = HiddenProfileItem.create!(membership: memberships(:alexis_base), subscription: subscriptions(:ror_alexis))
    login(alexis)
    assert_difference("HiddenProfileItem.count", -1) do
      delete("/base-secrete/profile/hidden_items/#{hidden_item.id}")
      assert_redirected_to("/base-secrete/profile/#{memberships(:alexis_base).id}")
    end
  end
end
