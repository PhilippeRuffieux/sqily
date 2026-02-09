require "test_helper"

class HomeworkTest < ActiveSupport::TestCase
  def setup
    Homework.any_instance.stubs(:save_file)
  end

  def test_for_skill
    assert_equal([], Homework.for_skill(skills(:html)).to_a)
    assert_equal([homeworks(:js_antoine)], Homework.for_skill(skills(:js)).to_a)
  end

  def test_approve
    (homework = homeworks(:js_antoine)).approve(users(:alexis))
    assert(homework.approved_at)
    refute(homework.rejected_at)
    assert(homework.subscription.completed_at)
  end

  def test_reject
    file = Rails.root.join("test/fixtures/files/image.jpg")
    (homework = homeworks(:js_antoine)).update!(file: file)
    assert_difference("ActionMailer::Base.deliveries.size") do
      (homework = homeworks(:js_antoine)).reject
      refute(homework.approved_at)
      assert(homework.rejected_at)
    end
  end

  def test_reject_and_keep_open
    file = Rails.root.join("test/fixtures/files/image.jpg")
    (homework = homeworks(:js_antoine)).update!(file: file)
    assert_difference("Homework.count") { homework.reject_and_keep_open }
    assert(homework.rejected_at)
  end

  def test_scope_to_approver
    assert_equal(1, Homework.to_approver(users(:alexis)).count)
    assert_equal(0, Homework.to_approver(users(:antoine)).count)
  end

  def test_scope_from_author
    assert_equal(0, Homework.from_author(users(:alexis)).count)
    assert_equal(1, Homework.from_author(users(:antoine)).count)
  end
end
