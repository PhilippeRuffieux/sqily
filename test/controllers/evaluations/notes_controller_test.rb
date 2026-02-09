require "test_helper"

class Evaluations::NotesControllerTest < ActionDispatch::IntegrationTest
  def test_create
    login(alexis)
    evaluation = evaluations(:js)
    subscription = subscriptions(:js_antoine)
    exam = Evaluation::Exam.create!(evaluation: evaluation, subscription: subscription, examiner: alexis)
    assert_emails(1) do
      assert_difference("exam.notes.count") do
        post(evaluation_notes_path(base, exam), params: {evaluation_note: {content: "Message"}})
        assert_redirected_to(evaluation_exams_path(base))
      end
    end
  end

  def test_create_when_accepted
    login(alexis)
    evaluation = evaluations(:js)
    subscription = subscriptions(:js_antoine)
    exam = Evaluation::Exam.create!(evaluation: evaluation, subscription: subscription, examiner: alexis)
    assert_emails(1) do
      assert_difference("exam.notes.count") do
        post(evaluation_notes_path(base, exam), params: {evaluation_note: {content: "Message"}, accept: true})
        assert_redirected_to(evaluation_exams_path(base))
      end
    end
    assert(exam.notes.last.is_accepted)
    assert(subscription.reload.completed_at)
  end

  def test_create_when_candidate_attempt_to_accept_is_own_exam
    login(antoine)
    evaluation = evaluations(:js)
    subscription = subscriptions(:js_antoine)
    exam = Evaluation::Exam.create!(evaluation: evaluation, subscription: subscription, examiner: alexis)
    assert_emails(1) do
      assert_difference("exam.notes.count") do
        post(evaluation_notes_path(base, exam), params: {evaluation_note: {content: "Message"}, accept: true})
        assert_redirected_to(evaluation_exams_path(base))
      end
    end
    refute(exam.notes.last.is_accepted)
    refute(subscription.reload.completed_at)
  end
end
