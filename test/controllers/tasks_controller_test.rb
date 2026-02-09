require "test_helper"

class TasksControllerTest < ActionController::TestCase
  def test_destroy
    login(alexis)
    task = tasks(:ror_ruby)
    assert_difference("Task.count", -1) do
      delete(:destroy, params: {permalink: base, skill_id: ror, id: task.id})
      assert_response(:success)
    end
  end

  def test_toggle_when_undone
    login(antoine)
    task = tasks(:ror_ruby)
    assert_difference("DoneTask.count") do
      post(:toggle, params: {permalink: base, skill_id: task.skill.id, id: task.id})
      assert_response(:success)
    end
  end

  def test_toggle_when_done
    login(alexis)
    task = tasks(:ror_ruby)
    assert_difference("DoneTask.count", -1) do
      post(:toggle, params: {permalink: base, skill_id: task.skill.id, id: task.id})
      assert_response(:success)
    end
  end
end
