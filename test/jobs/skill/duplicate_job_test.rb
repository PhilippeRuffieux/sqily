require "test_helper"

class Skill::DuplicateJobTest < ActiveJob::TestCase
  def test_perform_with_evaluations
    skill = nil
    assert_difference("hep.skills.count") do
      skill = Skill::DuplicateJob.perform_now(js, hep, admin, nil, duplicate_evaluations: true)
    end
    assert_equal(js.name, skill.name)
    assert_equal(js.description, skill.description)
    assert_equal(2, skill.evaluations.count)
    assert_equal([admin, admin], skill.evaluations.map(&:user))
  end

  def test_perform_without_evaluations
    skill = nil
    assert_difference("hep.skills.count") do
      skill = Skill::DuplicateJob.perform_now(js, hep, admin, nil, duplicate_evaluations: false)
    end
    assert_equal(0, skill.evaluations.count)
  end

  def test_perform_with_tasks
    skill = nil
    assert_difference("hep.skills.count") do
      skill = Skill::DuplicateJob.perform_now(ror, hep, admin)
    end
    assert_equal(ror.name, skill.name)
    assert_equal(ror.description, skill.description)
    assert_equal(2, skill.tasks.count)
  end

  def test_perform_when_user_is_not_member_of_community
    assert_no_difference("Skill.count") do
      assert_raises(ArgumentError) { Skill::DuplicateJob.perform_now(html, hep, alexis) }
    end
  end

  def test_perform_when_parent_skill_does_not_belong_to_community
    assert_no_difference("Skill.count") do
      assert_raises(ArgumentError) { Skill::DuplicateJob.perform_now(html, hep, alexis, js) }
    end
  end
end
