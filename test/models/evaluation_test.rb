require "test_helper"

class EvaluationTest < ActiveSupport::TestCase
  def test_one_version_per_user
    assert_equal(["js2", "html"], Evaluation.one_version_per_user.pluck(:title))
  end

  def test_destroyable
    evaluation = evaluations(:js)
    assert(evaluation.destroyable?)
    assert(evaluation.start(subscriptions(:js_antoine), "First exam"))
    refute(evaluation.destroyable?)
  end

  def test_start_succeeds
    first_exam, second_exam = nil
    evaluation = evaluations(:js)
    subscription = subscriptions(:js_antoine)

    assert_difference("Evaluation::Note.count") do
      assert_difference("Evaluation::Exam.count") do
        assert(first_exam = evaluation.start(subscription, "First exam"))
      end
    end

    assert_no_difference("Evaluation::Exam.count") do
      refute(evaluation.start(subscription, "Test"), "An exam is already ongoing")
    end

    assert(first_exam.cancel)

    assert_no_difference("Evaluation::Exam.count") do
      assert(second_exam = evaluation.start(subscription, "Second exam"))
      assert_equal(first_exam, second_exam)
      refute(first_exam.reload.is_canceled)
    end
  end

  def test_pick_examiner
    evaluation = evaluations(:js)
    valentin_subscription = js.subscribe(valentin)
    antoine_subscription = subscriptions(:js_antoine)

    valentin_exam = evaluation.start(valentin_subscription, "Test")
    assert_equal(alexis, valentin_exam.examiner, "Alexis is the only expert")

    valentin_exam.add_note(user: alexis, is_accepted: true, content: "Test")
    antoine_exam1 = evaluation.start(antoine_subscription, "Test")
    assert_equal(valentin, antoine_exam1.examiner, "Valentin is the less busy expert")

    antoine_exam1.update!(is_canceled: true)
    antoine_exam2 = evaluation.start(antoine_subscription, "Test")
    assert_equal(alexis, antoine_exam2.examiner, "Valentin is already the examiner for Antoine")

    assert_equal(2, evaluation.skill.experts.count)
    antoine_exam2.update!(is_canceled: true)
    evaluation.start(antoine_subscription, "Test")
    assert([alexis, valentin].include?(antoine_exam2.examiner), "All experts have be examiners of Antoine, pick simply the less busy")
  end

  def test_pick_examiner_in_same_team_first
    subscriptions(:js_antoine).complete
    valentin_membership = memberships(:valentin_base)
    js_valentin = js.subscribe(valentin)
    evaluation = evaluations(:js)

    valentin_membership.update!(team: teams(:backend))
    assert_equal(alexis, evaluation.pick_examiner_for(js_valentin))

    valentin_membership.update!(team: teams(:frontend))
    assert_equal(antoine, evaluation.pick_examiner_for(js_valentin))
  end
end
