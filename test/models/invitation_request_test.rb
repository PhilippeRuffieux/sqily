require "test_helper"

class InvitationRequestTest < ActiveSupport::TestCase
  def test_accept
    assert_difference("InvitationRequest.count", -1) do
      assert_difference("Invitation.count") do
        invitation_requests(:student_hep).accept!
      end
    end
  end

  def test_send_notification_to_moderators
    assert_difference("ActionMailer::Base.deliveries.size") do
      InvitationRequest.create!(community: communities(:base), email: "test@email.com")
    end
  end
end
