class EvaluationsController < ApplicationController
  before_action :find_skill, only: [:create, :new]
  before_action :find_evaluation, only: [:show, :edit, :update, :destroy, :enable, :disable]
  before_action :can_update_evaluation, only: [:edit, :update, :enable, :disable]
  before_action :must_be_membership

  def create
    Evaluation.create!(evaluation_params.merge(skill: @skill, user: current_user))
    redirect_to(skill_path(current_community, @skill))
  end

  def show
    render(partial: "/evaluations/exams/evaluation", locals: {evaluation: @evaluation}, layout: false)
  end

  def edit
    @subscription = Subscription.where(user: current_user, skill: @evaluation.skill_id).first
  end

  def update
    @evaluation.update!(evaluation_params)
    redirect_to(skill_path(current_community, @evaluation.skill))
  end

  def destroy
    @evaluation.destroy if current_user.permissions.destroy_evaluation?(@evaluation)
    redirect_to(skill_path(current_community, @evaluation.skill))
  end

  def new
    @evaluation = Evaluation.new(skill: @skill)
  end

  def disable
    @evaluation.touch(:disabled_at)
    redirect_to(skill_path(@evaluation.skill.community, @evaluation.skill))
  end

  def enable
    @evaluation.update!(disabled_at: nil)
    redirect_to(skill_path(@evaluation.skill.community, @evaluation.skill))
  end

  private

  def evaluation_params
    params.require(:evaluation).permit(:description, :title)
  end

  def find_skill
    @skill = current_community.skills.find(params[:skill_id])
    @subscription = @skill.subscriptions.find_by_user_id(current_user.id)
  end

  def find_evaluation
    @evaluation = Evaluation.find(params[:id])
  end

  def can_update_evaluation
    if !current_user.permissions.edit_evaluation?(@evaluation)
      redirect_to(skill_path(@evaluation.skill.community, @evaluation.skill), alert: "Vous n'êtes pas autorisé.")
    end
  end
end
