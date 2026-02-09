class HiddenProfileItem < ApplicationRecord
  belongs_to :membership
  belongs_to :workspace, optional: true
  belongs_to :subscription, optional: true

  def self.is_workspace_public?(workspace)
    return false if !workspace || !workspace.published_at
    user_ids = workspace.partnerships.pluck(:user_id)
    hidden_items = HiddenProfileItem.where(workspace: workspace).count
    private_profiles = Membership.where(user_id: user_ids, community_id: workspace.community_id, public: false).count
    hidden_items + private_profiles < workspace.partnerships.count
  end
end
