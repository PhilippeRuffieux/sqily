class Notification::HomeworkApproved < Notification
  belongs_to :homework

  Homework.after_save { Notification::HomeworkApproved.trigger(self) }

  def self.trigger(homework)
    return if !homework.approved_at || where(homework: homework).exists?
    if (membership = homework.subscription.membership)
      create!(homework: homework, to_membership: membership, created_at: homework.created_at)
    end
  end

  def self.replay
    Homework.find_each { |homework| trigger(homework) }
  end
end
