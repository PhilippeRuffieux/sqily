require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  def test_index
    login(alexis)
    Notification::VoteReceived.trigger(votes(:antoine_alexis_to_base))
    assert_difference("Notification.unread.count", -1) do
      get(notifications_path(base))
      assert_response(:success)
    end
  end
end
