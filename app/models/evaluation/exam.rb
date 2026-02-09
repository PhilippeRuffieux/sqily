class Evaluation::Exam < ActiveRecord::Base
  belongs_to :evaluation, class_name: "Evaluation"
  belongs_to :subscription
  belongs_to :examiner, class_name: "User"
  has_many :notes, class_name: "Evaluation::Note", dependent: :destroy

  validates_presence_of :examiner

  scope :of_user, ->(user) {
    joins(evaluation: [:skill], subscription: [:user])
      .where("subscriptions.user_id = ? OR evaluation_exams.examiner_id = ?", user.id, user.id)
  }

  scope :order_by_last_note, -> {
    order(Arel.sql("(select max(evaluation_notes.created_at) from evaluation_notes where evaluation_notes.exam_id = evaluation_exams.id) DESC"))
  }

  scope :in_community, ->(community) { joins(evaluation: :skill).where(skills: {community_id: community}) }

  scope :ongoing, -> { where("is_canceled = FALSE AND (SELECT count(*) from evaluation_notes WHERE exam_id = evaluation_exams.id AND is_accepted = TRUE) = 0") }

  scope :waiting_for_reply_from, ->(user) {
    where("(SELECT evaluation_notes.user_id FROM evaluation_notes WHERE exam_id = evaluation_exams.id AND created_at = " \
      "(SELECT max(created_at) FROM evaluation_notes WHERE exam_id = evaluation_exams.id) LIMIT 1) != ?", user)
  }

  def candidate_id
    subscription.user_id
  end

  def candidate
    subscription.user
  end

  def skill
    evaluation.skill
  end

  def waiting_for_review?
    return false if is_canceled?
    last_note = notes
      .min { |a, b| b.created_at <=> a.created_at }

    last_note.user_id != examiner.id
  end

  def completed?
    notes.where(is_accepted: true).first.present?
  end

  def on_going?
    !completed? && !is_canceled?
  end

  def add_note(params)
    if (user = params[:user]) && !user.permissions.can_accept_exam?(self)
      params = params.merge(is_accepted: false, is_rejected: false)
    end
    note = Evaluation::Note.new(params.merge(exam: self))
    ActiveRecord::Base.transaction do
      subscription.complete(user) if note.save && note.is_accepted
    end
    note
  end

  def active_sibling
    subscription.exams.where.not(id: id).ongoing.first
  end

  def cancel
    update(is_canceled: true) if on_going?
  end

  def resume
    update(is_canceled: false) if !active_sibling && is_canceled
  end
end
