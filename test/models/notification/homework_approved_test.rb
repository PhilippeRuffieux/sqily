require "test_helper"

class Notification::HomeworkApprovedTest < ActiveSupport::TestCase
  def test_after_create_callback
    homework = homeworks(:js_antoine)
    assert_no_difference("Notification::HomeworkApproved.count") { Notification::HomeworkApproved.trigger(homework) }
    assert_difference("Notification::HomeworkApproved.count") { homework.approve(alexis) }
    assert_no_difference("Notification::HomeworkApproved.count") { Notification::HomeworkApproved.trigger(homework) }
  end
end
