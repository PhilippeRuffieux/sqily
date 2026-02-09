class Notification::HomeworkPending < Notification
  belongs_to :homework

  Homework.after_save { Notification::HomeworkPending.trigger(self) }

  def self.trigger(homework)
    return if !homework.file_node || !homework.pending? || where(homework: homework).exists? || !homework.subscription.membership
    if homework.evaluation.membership
      create!(homework: homework, to_membership: homework.evaluation.membership, created_at: homework.created_at)
    end
  end

  def self.replay
    Homework.pending.find_each { |homework| trigger(homework) }
  end
end
