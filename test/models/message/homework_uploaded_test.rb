require "test_helper"

class Message::HomeworkUploadedTest < ActiveSupport::TestCase
  def test_callback
    Homework.any_instance.stubs(:save_file)
    homework = homeworks(:js_antoine)
    file = Rails.root.join("test/fixtures/files/image.jpg")
    assert_difference("ActionMailer::Base.deliveries.size") do
      assert_difference("Message::HomeworkUploaded.count") do
        homework.update!(file: file)
        homework.update!(file: file)
      end
    end
  end
end
