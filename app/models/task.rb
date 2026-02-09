class Task < ActiveRecord::Base
  belongs_to :skill
  validates_presence_of :title, :position

  include AwsFileStorage

  def self.all_done_by?(user)
    DoneTask.where(task_id: task_ids = pluck(:id), user_id: user.id).count == task_ids.size
  end

  def done_by?(user)
    DoneTask.where(task_id: id, user_id: user.id).exists?
  end
end
