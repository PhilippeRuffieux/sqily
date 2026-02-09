class PollAnswersController < ApplicationController
  before_action :authenticate_user
  before_action :must_be_membership

  def create
    choices = PollChoice.find(params[:choice_ids])
    choices.each { |choice| choice.answer(current_user) }
    redirect_to_poll_resource(choices.first.poll)
  end

  private

  def redirect_to_poll_resource(poll)
    if poll.skill_id
      redirect_to(skill_path(current_community, poll.skill))
    elsif poll.workspace_id
      redirect_to(workspace_path(current_community, poll.workspace))
    else
      redirect_to(skills_path(current_community))
    end
  end
end
