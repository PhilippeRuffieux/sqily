require "test_helper"

class HomeworksControllerTest < ActionController::TestCase
  def setup
    Homework.any_instance.stubs(:save_file)
    Message::HomeworkUploaded.any_instance.stubs(:save_file)
  end

  def test_upload
    login(users(:antoine))
    homework = homeworks(:js_antoine)
    file = fixture_file_upload("image.jpg", "image/jpeg")
    post(:upload, params: {id: homework.id, homework_file: file})
    assert_redirected_to("/base-secrete/skills/#{skills(:js).id}")
    assert(homework.reload.file_node)
  end

  def test_destroy
    login(users(:antoine))
    assert_difference("Homework.count", -1) do
      delete(:destroy, params: {id: homeworks(:js_antoine).id})
      assert_redirected_to("/base-secrete/skills/#{skills(:js).id}")
    end
  end

  def test_evaluate_approve
    Message::HomeworkUploaded.find_by_homework_id(uploaded_homework.id)
    post(:evaluate, params: {id: uploaded_homework.id, approve: true})
    assert_redirected_to("/base-secrete/messages?user_id=#{uploaded_homework.subscription.user_id}")
    assert(uploaded_homework.reload.approved_at)
  end

  def test_evaluate_reject
    post(:evaluate, params: {id: uploaded_homework.id, reject: true, comment: "Comment", file: fixture_file_upload("image.jpg", "image/jpeg")})
    assert_redirected_to("/base-secrete/messages?user_id=#{uploaded_homework.subscription.user_id}")
    assert(uploaded_homework.reload.rejected_at)
    message = Message::HomeworkUploaded.find_by_homework_id(uploaded_homework.id)
    assert_equal("Comment", message.text)
    assert(message.file_node)
  end

  private

  def uploaded_homework
    return @uploaded_homework if @uploaded_homework
    @uploaded_homework = homeworks(:js_antoine)
    @uploaded_homework.update!(file: Rails.root.join("test/fixtures/files/image.jpg"))
    @uploaded_homework
  end
end
