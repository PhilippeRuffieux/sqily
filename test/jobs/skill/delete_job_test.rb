require "test_helper"

class Skill::DeleteJobTest < ActiveJob::TestCase
  def test_perform
    workspaces(:ror_development).publish!(js)
    assert_no_difference("Workspace.count") do
      assert_difference("Evaluation.count", -2) do
        assert_difference("Subscription.count", -2) do
          assert_difference("Skill.count", -1) do
            Skill::DeleteJob.perform_now(js.id)
          end
        end
      end
    end
  end
end
