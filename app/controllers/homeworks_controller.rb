class HomeworksController < ApplicationController
  before_action :find_homework_for_current_user, only: %i[upload destroy]
  before_action :find_homework_for_expert, only: %i[evaluate]

  def upload
    @homework.update(file: params[:homework_file])
    redirect_to(skill_path(@skill.community, @skill))
  end

  def destroy
    @homework.destroy
    redirect_to(skill_path(@skill.community, @skill))
  end

  def evaluate
    if (message = Message::HomeworkUploaded.where(homework_id: @homework.id).last)
      message.update!(file: params[:file], text: params[:comment])
    end
    params[:approve] ? @homework.approve(current_user) : @homework.reject_and_keep_open
    redirect_to(messages_path(@homework.subscription.skill.community, user_id: @homework.subscription.user))
  end

  private

  def find_homework_for_current_user
    @homework = current_user.homeworks.find(params[:id])
    @skill = @homework.evaluation.skill
  end

  def find_homework_for_expert
    @homework = Homework.find(params[:id])
  end
end
