class DoneTask < ActiveRecord::Base
  belongs_to :task
  belongs_to :user

  scope :by_skill, ->(skill) { joins(:task).where(tasks: {skill: skill}) }
end
