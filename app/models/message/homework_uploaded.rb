class Message::HomeworkUploaded < Message
  belongs_to :homework
  validates_presence_of :homework_id

  include AwsFileStorage

  scope :in_community, ->(community) { joins(homework: :evaluation).where(evaluations: {skill_id: community.skills.ids}) }

  Homework.after_save { Message::HomeworkUploaded.trigger(self) }

  after_create { send_notification }

  def self.trigger(homework)
    return if !homework.file_node
    attributes = {from_user_id: homework.subscription.user_id, to_user_id: homework.evaluation.user.id, homework_id: homework.id}
    where(attributes).first || create!(attributes)
  end

  def send_notification
    UserMailer.homework_uploaded(homework).deliver_now
  end
end
