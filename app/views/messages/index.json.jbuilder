json.new_messages @messages.any? ? render(partial: "messages/list", formats: [:html]) : nil
json.next_url url_for(params.permit(params.keys).merge(after: @messages.maximum(:id) || params[:after])) if params[:after]
json.previous_url (@messages.size == 25) ? url_for(params.permit(params.keys).merge(before: @messages.minimum(:id))) : nil if params[:before]
json.skill_ids_with_unread_messages @skill_ids_with_unread_messages

if @edited_messages
  json.edited_messages do
    json.array! @edited_messages do |message|
      json.id message.id
      json.html render_message message
    end
  end
end
