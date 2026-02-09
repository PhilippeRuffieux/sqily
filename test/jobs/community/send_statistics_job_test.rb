require "test_helper"

class Community::SendStatisticsJobTest < ActiveJob::TestCase
  def test_perform
    assert_emails(1) do
      Community::SendStatisticsJob.perform_now("admin@sqily.test")
    end
  end
end
