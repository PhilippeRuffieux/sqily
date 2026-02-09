class CancelEventJob < ActiveJob::Base
  queue_as :default

  def perform(event_id)
    if (event = Event.find_by_id(event_id))
      event.users.where.not(id: event.user_id).each.each do |user|
        UserMailer.event_cancelled(event, user).deliver_now
      end
      event.destroy
    end
  end
end
