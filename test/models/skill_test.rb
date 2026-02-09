require "test_helper"

class SkillTest < ActiveSupport::TestCase
  def test_experts
    assert_equal(["Alexis"], skills(:js).experts.pluck(:name))
  end

  def test_startable_by_when_a_skill_is_mandatory
    assert(html.startable_by?(alexis))
    refute(css.startable_by?(alexis))
    html.subscribe(alexis).complete(antoine)
    assert(css.startable_by?(alexis))
    css.update!(minimum_prerequisites: 2)
    refute(css.startable_by?(alexis))
  end

  def test_startable_by_when_parent_prerequisite
    programming = skills(:programming)
    assert(programming.startable_by?(antoine))
    assert(js.startable_by?(antoine))
    programming.update!(minimum_prerequisites: 2)
    refute(programming.startable_by?(antoine))
    refute(js.reload.startable_by?(antoine))
  end

  def test_viewable_by
    community = communities(:base)
    alexis, antoine = users(:alexis), users(:antoine)
    skills(:ror).update(published_at: nil, creator: alexis)
    assert(community.skills.viewable_by(alexis).pluck(:name).include?("Ruby on Rails"))
    refute(community.skills.viewable_by(antoine).pluck(:name).include?("Ruby on Rails"))
  end

  def test_subscribe_to_child_skill
    assert_difference("Subscription.count", 2) { skills(:ror).subscribe(valentin) }
  end

  def test_unsubscribe_from_child_skill
    Evaluation::Draft.create!(evaluation: evaluations(:js), subscription: subscriptions(:js_alexis), content: "Test")
    assert((programming = subscriptions(:programming_alexis)).completed_at)
    assert_difference("Subscription.count", -1) { skills(:js).unsubscribe(alexis) }
    refute(programming.reload.completed_at)
    assert_difference("Subscription.count", -2) { skills(:ror).unsubscribe(alexis) }
  end

  def test_can_have_children
    skill = Skill.new(parent: Skill.new)
    refute(skill.can_have_children?)
    skill.parent = nil
    assert(skill.can_have_children?)
    skill.evaluations = [Evaluation.new]
    refute(skill.can_have_children?)
  end

  def test_remove_foreign_previous_prerequisites
    ror = skills(:ror)
    assert_no_difference("ror.prerequisites.count") { ror.remove_foreign_prerequisites }
    ror.update!(parent: nil)
    assert_difference("ror.prerequisites.count", -1) { ror.remove_foreign_prerequisites }
  end

  def test_remove_foreign_next_prerequisites
    js = skills(:js)
    assert_no_difference("js.next_prerequisites.count") { js.remove_foreign_prerequisites }
    js.update!(parent: nil)
    assert_difference("js.next_prerequisites.count", -1) { js.remove_foreign_prerequisites }
  end

  def test_reorganize_subscriptions
    design, programming = skills(:design), skills(:programming)
    assert_difference("antoine.subscriptions.where(skill: programming).count", -1) { js.update!(parent: design) }
    assert_difference("antoine.subscriptions.where(skill: programming).count") { js.update!(parent: programming) }
    assert_difference("antoine.subscriptions.where(skill: programming).count", -1) { js.update!(parent: nil) }
    assert_difference("antoine.subscriptions.where(skill: programming).count") { js.update!(parent: programming) }
  end

  def test_cannot_not_be_parent_of_itself
    programming = skills(:programming)
    refute(programming.update(parent: programming))
    assert(programming.errors[:parent_id])
  end
end
