module EventsHelper
  def event_waiting_list_position(event, user)
    index = event.waiting_participations.order(:created_at).pluck(:user_id).index(user.id)
    index ? index + 1 : index
  end

  def participation_status_class(participation)
    case participation.confirmed
    when true then "present"
    when false then "absent"
    end
  end
end
