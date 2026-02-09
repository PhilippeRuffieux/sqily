require "test_helper"

class SkillFormTest < ActiveSupport::TestCase
  def setup
    Evaluation.any_instance.stubs(:save_file)
  end

  def test_create
    form = SkillForm.new
    assert_difference("admin.subscriptions.count") do
      assert_difference("Task.count", 2) do
        assert_difference("Skill.count") do
          form.create(create_params)
        end
      end
    end
    assert_equal(admin, form.skill.creator)
  end

  def test_create_with_error
    form = SkillForm.new
    assert_no_difference("Task.count", 2) do
      assert_no_difference("Skill.count") do
        form.create(create_params.merge(name: ""))
      end
    end
    assert_equal(2, form.skill.tasks.size, "It keeps new tasks")
  end

  def test_update
    task = tasks(:ror_ruby)
    SkillForm.update(ror, {tasks: [{id: task.id, title: "New title"}]})
    assert_equal("New title", task.reload.title)
  end

  def test_update_when_parent_is_from_another_community
    hep_equations = skills(:hep_equations)
    assert(hep_equations.can_have_children?)
    SkillForm.update(ror, {parent_id: hep_equations.id})
    assert_equal(skills(:programming), ror.parent)
  end

  def test_update_when_parent_cannot_have_children
    js = skills(:js)
    refute(js.can_have_children?)
    SkillForm.update(ror, {parent_id: js.id})
    assert_equal(skills(:programming), ror.parent)
  end

  def create_params
    {
      name: "Test",
      description: "Test",
      creator: admin,
      community: hep,
      tasks: [{title: "Task 1", position: 1}, {title: "Task 2", position: 2}]
    }
  end
end
