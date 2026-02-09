require "test_helper"

class PasswordResetTest < ActiveSupport::TestCase
  def test_send_to
    assert_difference("ActionMailer::Base.deliveries.size") do
      assert_difference("PasswordReset.count") do
        assert(PasswordReset.send_to("alexis@basesecrete.test", "127.0.0.1"))
      end
    end
  end

  def test_send_to_when_email_does_not_exist
    assert_no_difference("PasswordReset.count") do
      refute(PasswordReset.send_to("does@no.exist", "127.0.0.1"))
    end
  end

  def test_proceed
    reset = password_resets(:alexis)
    assert_equal(users(:alexis), PasswordReset.proceed(reset.token))
    assert(reset.reload.completed_at)

    reset.touch(:expired_at)
    refute(PasswordReset.proceed(reset.token))
  end
end
