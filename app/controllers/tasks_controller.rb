class TasksController < ApplicationController
  before_action :find_skill
  before_action :find_task, only: [:toggle]

  def destroy
    @skill.tasks.find(params[:id]).destroy
    head(:ok)
  end

  def toggle
    if @task.done_by?(current_user)
      DoneTask.where(user: current_user, task: @task).first.destroy
    else
      DoneTask.create!(user: current_user, task: @task)
    end
    head(:ok)
  end

  private

  def find_skill
    @skill = current_community.skills.find(params[:skill_id])
  end

  def find_task
    @task = @skill.tasks.find(params[:id])
  end
end
