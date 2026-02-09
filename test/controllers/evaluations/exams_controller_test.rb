require "test_helper"

class Evaluations::ExamsControllerTest < ActionDispatch::IntegrationTest
  def test_create
    login(antoine)
    evaluation = evaluations(:js)
    subscriptions(:js_antoine)

    assert_emails(1) do
      assert_difference("Evaluation::Exam.count") do
        post(create_evaluation_exams_path(base, evaluation), params: {evaluation_draft: {content: "Exam"}})
      end
    end
    assert_redirected_to(evaluation_exam_path(id: Evaluation::Exam.last))

    assert_no_emails do
      assert_no_difference("Evaluation::Exam.count") do
        post(create_evaluation_exams_path(base, evaluation), params: {evaluation_draft: {content: "Exam"}})
      end
    end
    assert_redirected_to(evaluation_exam_path(id: Evaluation::Exam.last))
  end

  def test_create_when_there_is_no_examiners
    login(antoine)
    evaluation = evaluations(:js)
    subscriptions(:js_antoine)
    evaluation.skill.subscriptions.each(&:uncomplete)

    assert_no_difference("Evaluation::Exam.count") do
      post(create_evaluation_exams_path(base, evaluation), params: {evaluation_draft: {content: "Exam"}})
    end
    assert_redirected_to(skill_path(base, evaluation.skill))
  end

  def test_change_examiner
    login(antoine)
    evaluation = evaluations(:js)
    subscription = subscriptions(:js_antoine)
    js.subscribe(valentin).touch(:completed_at)
    old_exam = evaluation.start(subscription, "Test exam")

    assert_difference("Evaluation::Exam.count") do
      post(change_examiner_evaluation_exam_path(base, old_exam))
    end
    assert(old_exam.reload.is_canceled?)
    assert_redirected_to(evaluation_exam_path(base, new_exam = Evaluation::Exam.last))
    assert_equal("Test exam", new_exam.notes.first.content)

    assert_no_difference("Evaluation::Exam.count") do
      post(change_examiner_evaluation_exam_path(base, new_exam))
      assert_response(:redirect, "Redirect randomly either to old or new exam")
    end
  end
end
