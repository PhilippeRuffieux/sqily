require "test_helper"

class Notification::HomeworkRejectedTest < ActiveSupport::TestCase
  def test_after_create_callback
    homework = homeworks(:js_antoine)
    assert_no_difference("Notification::HomeworkRejected.count") { Notification::HomeworkRejected.trigger(homework) }
    assert_difference("Notification::HomeworkRejected.count") { homework.reject }
    assert_no_difference("Notification::HomeworkRejected.count") { Notification::HomeworkRejected.trigger(homework) }
  end
end
