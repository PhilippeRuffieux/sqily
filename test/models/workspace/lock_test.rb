require "test_helper"

class Workspace::LockTest < ActiveSupport::TestCase
  def test_take
    workspace = workspaces(:ror_development)
    assert_difference("Workspace::Lock.count") { assert(Workspace::Lock.take(workspace, alexis)) }
    assert_no_difference("Workspace::Lock.count") { refute(Workspace::Lock.take(workspace, antoine)) }
    assert_no_difference("Workspace::Lock.count") { assert(Workspace::Lock.take(workspace, alexis)) }
  end
end
