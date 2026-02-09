class Evaluation::Note < ActiveRecord::Base
  belongs_to :exam, class_name: "Evaluation::Exam"
  belongs_to :user

  validates_presence_of :content, unless: :is_accepted?

  scope :accepted, -> { where(is_accepted: true) }

  def attachment_path
    "#{AwsFileStorage.aws_bucket_prefix}/evaluation_notes/attachments/#{id}/"
  end

  def send_email
    if exam.examiner_id == user_id && !is_accepted
      ExamMailer.rejected(self).deliver_now
    elsif exam.subscription.user_id == user_id
      ExamMailer.created(exam).deliver_now
    end
  end
end
