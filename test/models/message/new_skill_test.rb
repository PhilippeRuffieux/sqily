require "test_helper"

class Message::NewSkillTest < ActiveSupport::TestCase
  def test_callback
    js.update!(published_at: nil)
    assert_no_difference("Message::NewSkill.count") { Message::NewSkill.trigger(skills(:js)) }
    js.touch(:published_at)
    assert_difference("Message::NewSkill.count") do
      Message::NewSkill.trigger(js)
      Message::NewSkill.trigger(js)
    end
  end
end
