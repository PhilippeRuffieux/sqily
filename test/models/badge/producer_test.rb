require "test_helper"

class Badge::ProducerTest < ActiveSupport::TestCase
  def test_trigger
    assert_no_difference("Badge::Producer.count") { create_and_publish_workspace }
    assert_difference("Badge::Producer.count") { create_and_publish_workspace }
    assert_no_difference("Badge::Producer.count") { create_and_publish_workspace }
  end

  private

  def create_and_publish_workspace
    form = WorkspaceForm.create(community: base, owner: alexis)
    form.workspace.publish!
  end
end
