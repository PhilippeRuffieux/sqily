class PollsController < ApplicationController
  before_action :authenticate_user
  before_action :must_be_membership

  def create
    @poll = Poll.new(poll_params.merge(user: current_user))
    build_choices(params[:choices], @poll)
    if @poll.save
      redirect_to_poll_resource(@poll)
    else
      render(:new)
    end
  end

  def show
    @poll = Poll.find(params[:id])
    render_not_found if !@poll.editable_by?(current_user)
  end

  def destroy
    (@poll = Poll.find(params[:id])).destroy
    redirect_to_poll_resource(@poll)
  end

  private

  def poll_params
    params.require(:poll).permit(:title, :community_id, :skill_id, :workspace_id, :finished_at, :single_answer)
  end

  def build_choices(choices, poll)
    choices.map { |title| poll.choices.new(title: title) if title.present? }
  end

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
