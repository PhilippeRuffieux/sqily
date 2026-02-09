require "test_helper"

class Notification::PollFinishedTest < ActiveSupport::TestCase
  def test_trigger
    poll = polls(:alexis_poll_to_base)
    PollAnswer.create!(user: antoine, choice: poll_choices(:choice1))
    assert_no_difference("Notification::PollFinished.count") { Notification::PollFinished.trigger_for_last_24h }
    poll.update!(finished_at: Time.now)
    assert_difference("Notification::PollFinished.count") { Notification::PollFinished.trigger_for_last_24h }
    assert_no_difference("Notification::PollFinished.count") { Notification::PollFinished.trigger_for_last_24h }
  end
end
