require "test_helper"

class Evaluation::ExamTest < ActiveSupport::TestCase
  def test_scope_of_user
    exam = nil

    assert_difference("Evaluation::Exam.of_user(alexis).count") do
      exam = evaluations(:js).start(subscriptions(:js_antoine), "...")
    end

    assert_difference("Evaluation::Exam.of_user(admin).count") do
      exam.update!(examiner: admin)
    end
  end

  def test_cancel_resume
    evaluation = evaluations(:js)
    subscription = subscriptions(:js_antoine)

    exam1 = evaluation.start(subscription, "text")
    refute(exam1.active_sibling)
    assert(exam1.cancel)
    refute(exam1.cancel)
    assert(exam1.resume)
    refute(exam1.resume)
    assert(exam1.cancel)
  end
end
