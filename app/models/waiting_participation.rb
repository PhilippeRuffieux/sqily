class WaitingParticipation < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  def register
    event.register(user)
    if event.registered?(user)
      destroy
      UserMailer.waiting_participation_finished(self).deliver_now
    end
  end
end
