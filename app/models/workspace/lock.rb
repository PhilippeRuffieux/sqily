class Workspace::Lock < ActiveRecord::Base
  belongs_to :workspace
  belongs_to :user

  def self.last_active(workspace)
    where("workspace_id = ? AND taken_at > ?", workspace.id, 15.seconds.ago).order("taken_at DESC").first
  end

  def self.take(workspace, user)
    return if (lock = last_active(workspace)) && lock.user_id != user.id
    lock ||= find_or_initialize_by(workspace_id: workspace.id, user_id: user.id)
    lock.update!(taken_at: Time.now.utc)
    lock
  end
end
