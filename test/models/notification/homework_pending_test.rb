require "test_helper"

class Notification::HomeworkPendingTest < ActiveSupport::TestCase
  def test_after_create_callback
    homework = homeworks(:js_antoine)
    assert_no_difference("Notification::HomeworkPending.count") { Notification::HomeworkPending.trigger(homework) }
    assert_difference("Notification::HomeworkPending.count") { homework.update!(file: Rails.root.join("test/fixtures/files/image.jpg")) }
    assert_no_difference("Notification::HomeworkPending.count") { Notification::HomeworkPending.trigger(homework) }
  end
end
