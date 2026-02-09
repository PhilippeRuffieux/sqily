require "test_helper"

class HiddenProfileItemTest < ActiveSupport::TestCase
  def test_is_workspace_public?
    workspace = workspaces(:ror_development)
    refute(HiddenProfileItem.is_workspace_public?(workspace))

    workspace.approve!
    workspace.publish!
    assert(HiddenProfileItem.is_workspace_public?(workspace))

    hidden_item1 = HiddenProfileItem.create!(membership: memberships(:alexis_base), workspace: workspace)
    hidden_item2 = HiddenProfileItem.create!(membership: memberships(:valentin_base), workspace: workspace)
    refute(HiddenProfileItem.is_workspace_public?(workspace))

    hidden_item1.destroy
    hidden_item2.destroy
    assert(HiddenProfileItem.is_workspace_public?(workspace))

    memberships(:alexis_base).update!(public: false)
    memberships(:valentin_base).update!(public: false)
    refute(HiddenProfileItem.is_workspace_public?(workspace))
  end
end
