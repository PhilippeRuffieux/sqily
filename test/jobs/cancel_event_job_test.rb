require "test_helper"

class CancelEventJobTest < ActiveJob::TestCase
  def test_perform_does_not_send_email_to_creator
    assert_emails(0) do
      assert_difference("Event.count", -1) do
        CancelEventJob.perform_now(js_demo.id)
      end
    end
  end

  def test_perform_sends_email_to_participants
    js_demo.register(antoine)
    assert_emails(1) do
      assert_difference("Event.count", -1) do
        CancelEventJob.perform_now(js_demo.id)
      end
    end
  end
end
