class ExamMailerPreview < ActionMailer::Preview
  def created
    ExamMailer.created(Evaluation::Exam.last)
  end

  def rejected
    ExamMailer.rejected(Evaluation::Note.last)
  end
end
