require "test_helper"

class Community::DeleteJobTest < ActiveJob::TestCase
  def test_perform
    assert_difference("Community.count", -1) { Community::DeleteJob.perform_now(hep.id) }
    assert_difference("Community.count", -1) { Community::DeleteJob.perform_now(base.id) }
  end
end
