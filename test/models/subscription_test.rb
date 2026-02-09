require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  def test_toggle_pinned_at
    subscription = subscriptions(:ror_alexis)
    assert_difference("Subscription.pinned.count") { assert(subscription.toggle_pinned_at) }
    assert_difference("Subscription.pinned.count", -1) { refute(subscription.toggle_pinned_at) }
  end

  def test_complete
    programming_subscription = subscriptions(:programming_antoine)
    js_subscription = subscriptions(:js_antoine)
    js_subscription.complete(alexis)
    assert(js_subscription.completed_at)
    assert_equal(alexis, js_subscription.validator)
    refute(programming_subscription.reload.completed_at)

    ror_subscription = ror.subscribe(antoine)
    ror_subscription.complete(alexis)
    assert(programming_subscription.reload.completed_at)
    refute(programming_subscription.validator)
  end

  def test_complete_when_all_skills_are_not_mandatory
    skills(:ror).update!(mandatory: false)
    programming_subscription = subscriptions(:programming_antoine)
    js_subscription = subscriptions(:js_antoine)
    js_subscription.complete(alexis)
    assert(js_subscription.completed_at)
    assert_equal(alexis, js_subscription.validator)
    assert(programming_subscription.reload.completed_at)
  end

  def test_uncomplete
    subscription = subscriptions(:js_antoine)
    exam = Evaluation::Exam.create!(evaluation: evaluations(:js), subscription: subscription, examiner: alexis)
    exam.add_note(user: alexis, is_accepted: true, content: "Test")
    assert(exam.reload.completed?)
    assert(subscription.reload.completed_at)
    subscription.uncomplete
    refute(exam.reload.completed?)
    assert(exam.is_canceled)
  end

  def test_uncomplete_when_parent_skill_has_been_achieved
    assert((programming = subscriptions(:programming_alexis)).completed_at)
    subscriptions(:ror_alexis).uncomplete
    refute(programming.reload.completed_at)
  end

  def test_in_community
    assert_equal([subscriptions(:equations_admin)], Subscription.in_community(communities(:hep)).to_a)
  end

  def test_with_unread_messages
    subscriptions(:js_alexis).update_columns(last_read_at: messages(:alexis_to_js).created_at)
    subscriptions(:ror_alexis).update_columns(last_read_at: messages(:alexis_file_to_ror).created_at)
    assert_equal([subscriptions(:js_antoine)], Subscription.with_unread_messages.to_a)
  end

  def test_refresh_completed_at_after_skill_mandatory_changed
    parent_subscription, child_subscription = subscriptions(:programming_antoine), subscriptions(:js_antoine)
    child_subscription.complete(alexis)
    refute(parent_subscription.completed_at)
    ror.update!(mandatory: false)
    assert(parent_subscription.reload.completed_at)
    ror.update!(mandatory: true)
    refute(parent_subscription.reload.completed_at)
  end

  def test_refresh_completed_at_after_skill_parent_changed
    programming = subscriptions(:programming_antoine)
    design = subscriptions(:design_antoine)
    js = subscriptions(:js_antoine)
    js.complete(alexis)
    refute(programming.completed_at)
    ror.update!(parent: skills(:design))
    refute(design.reload.completed_at)
    assert(programming.reload.completed_at)
    ror.update!(parent: skills(:programming))
    assert(design.reload.completed_at)
    refute(programming.reload.completed_at)
  end
end
