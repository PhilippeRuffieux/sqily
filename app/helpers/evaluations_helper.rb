module EvaluationsHelper
  def evaluation_label(evaluation)
    name = [evaluation.user.name, l(evaluation.created_at.to_date), evaluation.title].compact.join(" - ")
    t("skills.evaluations.choices.evaluation_of", name: name)
  end

  def evaluations_of(user)
    skill_ids = current_community.skills.published.pluck(:id)
    Evaluation.where(user_id: user.id, skill_id: skill_ids).one_version_per_user
  end

  def exam_css_status(exam, user = current_user)
    return "finished" unless exam.on_going?
    if exam.waiting_for_review?
      "pinned" if exam.examiner_id == user.id
    elsif exam.candidate_id == user.id
      "pinned"
    end
  end

  def evaluation_event_date(exam)
    # most recent date between note and exam updated at
    last_note_date = exam.notes.order(created_at: :desc).first&.created_at
    [last_note_date, exam.updated_at].compact.max
  end

  def exam_title_status(exam, user = current_user)
    interlocutor = (current_user == exam.candidate) ? exam.examiner : exam.candidate
    if exam.completed?
      if interlocutor == exam.candidate
        octicon("check") + t("evaluations.exams.status.completed_by_interlocutor", user: interlocutor.name)
      else
        octicon("check") + t("evaluations.exams.status.completed_by_you", user: interlocutor.name)
      end
    elsif exam.is_canceled?
      octicon("circle-slash") + t("evaluations.exams.status.cancelled")
    elsif exam.notes.order(:created_at).last.user == current_user
      octicon("arrow-switch") + t("evaluations.exams.status.waiting_for_interlocutor", user: interlocutor.name)
    else
      octicon("arrow-switch") + t("evaluations.exams.status.waiting_for_your", user: interlocutor.name)
    end
  end

  def evaluations_to_options(evaluations, selected = nil)
    selected = skill_evaluation_path(current_community, selected) if selected
    options_for_select(evaluations.map { |e| [evaluation_label(e), skill_evaluation_path(current_community, e)] }, selected)
  end
end
