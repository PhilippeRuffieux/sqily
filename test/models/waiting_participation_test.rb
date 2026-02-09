require "test_helper"

class WaitingParticipationTest < ActiveSupport::TestCase
  def test_register
    js_demo.update!(max_participations: 1)
    js_demo.register(users(:antoine))
    assert_emails(1) do
      assert_difference("WaitingParticipation.count", -1) do
        assert_no_difference("Participation.count") { js_demo.unregister(alexis) }
        assert(js_demo.registered?(antoine))
      end
    end
  end
end
