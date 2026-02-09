class Evaluations::NotesController < ApplicationController
  def create
    @exam = Evaluation::Exam.find(params[:id])
    @note = @exam.add_note(note_params)
    if @note.persisted?
      redirect_to(evaluation_exams_path)
      @note.send_email
    else
      @notes = @exam.notes.order(created_at: :asc)
      @evaluation = @exam.evaluation
      render("/evaluations/exams/show")
    end
  end

  private

  def note_params
    hash = params.require(:evaluation_note).permit(:content)
    hash[:is_accepted] = params[:accept].present?
    hash[:is_rejected] = params[:reject].present?
    hash[:user] = current_user
    hash
  end
end
