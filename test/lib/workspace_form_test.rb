require "test_helper"

class WorkspaceFormTest < ActiveSupport::TestCase
  def test_create
    form = WorkspaceForm.new
    assert_difference("Workspace::Version.count") do
      assert_difference("Workspace::Partnership.count") do
        assert_difference("Workspace.count") { form.create(owner: alexis, community: base) }
      end
    end
  end
end
