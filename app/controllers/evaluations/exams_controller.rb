class Evaluations::ExamsController < ApplicationController
  before_action :must_be_membership

  def index
    @exams = Evaluation::Exam.in_community(current_community).of_user(current_user).order_by_last_note
  end

  def create
    evaluation = Evaluation.find(params[:evaluation_id])
    subscription = Subscription.where(user_id: current_user.id, skill_id: evaluation.skill_id).first

    if (active_exam = subscription.exams.ongoing.first)
      redirect_to(evaluation_exam_path(current_community, active_exam), alert: I18n.t("evaluations.exams.already_one_in_progress"))
    elsif (exam = evaluation.start(subscription, params[:evaluation_draft][:content])).persisted?
      ExamMailer.created(exam).deliver_now
      redirect_to(evaluation_exam_path(id: exam.id))
    else
      redirect_to(skill_path(current_community, evaluation.skill), alert: t("evaluations.exams.unsubmittable"))
    end
  end

  def cancel
    exam = Evaluation::Exam.joins(:subscription).where(subscriptions: {user_id: current_user}).find(params[:id])
    exam.cancel
    redirect_to(skill_path(current_community, exam.subscription.skill))
  end

  def resume
    exam = Evaluation::Exam.joins(:subscription).where(subscriptions: {user_id: current_user}).find(params[:id])
    if (active_exam = exam.active_sibling)
      redirect_to(evaluation_exam_path(current_community, active_exam), alert: I18n.t("evaluations.exams.already_one_in_progress"))
    else
      exam.resume
      redirect_to(evaluation_exam_path(current_community, exam))
    end
  end

  def change_examiner
    exam = Evaluation::Exam.joins(:subscription).where(subscriptions: {user_id: current_user}).find(params[:id])
    subscription = exam.subscription
    evaluation = exam.evaluation
    exam.cancel

    if (active_exam = exam.subscription.exams.ongoing.first)
      redirect_to(evaluation_exam_path(current_community, active_exam), alert: I18n.t("evaluations.exams.already_one_in_progress"))
    else
      exam = evaluation.start(subscription, exam.notes.first.content)
      redirect_to(evaluation_exam_path(id: exam.id))
    end
  end

  def show
    @exam = Evaluation::Exam.joins(:evaluation, :subscription, notes: [:user]).find(params[:id])
    @notes = @exam.notes.order(created_at: :asc)
    render_not_found if !current_user.permissions.read_exam?(@exam)
  end
end
