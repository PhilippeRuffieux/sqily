class ExamMailer < ApplicationMailer
  helper :users

  def created(exam)
    mail(subject: "Défi en attente de validation", to: (@exam = exam).examiner.email)
  end

  def rejected(note)
    (@note = note).exam.examiner
    mail(subject: "Des nouvelles de votre défi", to: @note.exam.subscription.user.email)
  end
end
