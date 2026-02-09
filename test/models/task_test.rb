require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def test_all_done_by?
    refute(ror.tasks.all_done_by?(alexis))
    DoneTask.create!(user: alexis, task: tasks(:ror_psql))
    assert(ror.tasks.all_done_by?(alexis))
  end

  def test_done_by?
    assert(tasks(:ror_ruby).done_by?(alexis))
    refute(tasks(:ror_psql).done_by?(alexis))
  end
end
