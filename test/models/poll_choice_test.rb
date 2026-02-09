require "test_helper"

class PollChoiceTest < ActiveSupport::TestCase
  def test_answer
    choice = poll_choices(:choice1)
    assert_difference("PollAnswer.count") { choice.answer(alexis) }
    assert_no_difference("PollAnswer.count") { choice.answer(alexis) }
  end

  def test_answer_when_user_does_not_belong_to_same_community
    assert_no_difference("PollAnswer.count") { poll_choices(:choice1).answer(admin) }
  end
end
