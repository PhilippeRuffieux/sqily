module MessagesHelper
  def format_message_timestamp(message)
    message.created_at.strftime("%H:%M")
  end

  def messages_auto_pull_url(messages)
    if !params[:pinned] && !params[:to]
      messages_path(current_community,
        skill_id: @skill.try(:id),
        user_id: @user.try(:id),
        workspace_id: @workspace.try(:id),
        after: messages.maximum(:id))
    end
  end

  IMAGE_EXTENSIONS = [".jpg", ".jpeg", ".png"]

  def is_message_attachment_an_image?(message)
    message.file_name && IMAGE_EXTENSIONS.include?(File.extname(message.file_name).downcase)
  end

  AUDIO_EXTENSIONS = [".ogg", ".mp3"]

  def is_message_attachment_audio?(message)
    message.file_name && AUDIO_EXTENSIONS.include?(File.extname(message.file_name).downcase)
  end

  VIDEO_EXTENSIONS = [".mp4"]

  def is_message_attachment_video?(message)
    message.file_name && VIDEO_EXTENSIONS.include?(File.extname(message.file_name).downcase)
  end

  def highlight_current_user(text)
    return text unless current_user
    escaped_username = Regexp.escape(current_user.name)
    text.gsub(/(?<![\w#{escaped_username}])#{escaped_username}(?![\w#{escaped_username}])/i, "<mark>\\0</mark>")
  end

  def format_message_text(message)
    auto_embed(message_hash_tags_to_links(format_text(message.text), message)).html_safe
  end

  def message_hash_tags_to_links(text, message)
    HashTag.split(text = text.dup).each do |tag|
      url = if message.to_skill_id
        messages_skill_path(current_community.permalink, id: message.to_skill_id, hash_tag: HashTag.normalize(tag))
      else
        messages_community_path(current_community.permalink, hash_tag: HashTag.normalize(tag))
      end
      text.gsub!(/(\A|\s)##{tag}\b/, "\\1" + link_to("##{tag}", url))
    end
    text.html_safe
  end

  def render_message(message)
    path = "/messages/#{message.class.to_s.split("::").last.underscore}"
    render(partial: path, locals: {message: message}, formats: [:html])
  end

  def unread_messages_count(user)
    Message.from_a_member_of(current_community).unread.to_user(user).count
  end

  def current_user_unread_messages_from(users)
    rows = Message.unread.where(from_user: users.ids, to_user: current_user).group(:from_user_id).pluck(Arel.sql("from_user_id, COUNT(*)"))
    rows.each_with_object({}) do |row, hash|
      hash[row[0]] = row[1]
    end
  end

  def messages_from_oldest_to_newest(messages)
    # messages.any? && messages.first.created_at > messages.last.created_at ? messages.reverse_order : messages
    (messages.any? && messages.first.created_at > messages.last.created_at) ? messages.reverse : messages
  end

  def messages_previous_page_params(messages)
    {
      permalink: current_community,
      before: messages.map(&:id).min,
      after: nil,
      skill_id: @skill.try(:id),
      user_id: @user.try(:id),
      pinned: params[:pinned]
    }
  end

  def messages_next_page_params(messages)
    {
      permalink: current_community,
      after: messages.map(&:id).max,
      before: nil,
      skill_id: @skill.try(:id),
      user_id: @user.try(:id),
      pinned: params[:pinned]
    }
  end

  def messages_previous_page_url(messages)
    messages_path(messages_previous_page_params(messages)) if messages.size == 25
  end

  def messages_next_page_url(messages)
    messages_path(messages_next_page_params(messages)) if (params[:to] || params[:after]) && messages.any?
  end

  def message_permalink(message, user = nil)
    if message.to_skill_id
      community = respond_to?(:current_community) ? current_community : message.to_skill.community
      # messages_skill_url(community, message.to_skill_id, to: message.created_at.iso8601(6))
      messages_skill_url(community, message.to_skill_id, to: message)
    elsif message.to_user_id
      community = respond_to?(:current_community) ? current_community : message.to_user.communities.first
      user ||= current_user if respond_to?(:current_user)
      # messages_url(community, user_id: user.id == message.from_user_id ? message.to_user_id : message.from_user_id, to: message.created_at.iso8601(6))
      messages_url(community, user_id: (user.id == message.from_user_id) ? message.to_user_id : message.from_user_id, to: message)
    elsif message.to_workspace_id
      community = respond_to?(:current_community) ? current_community : message.to_workspace.community
      workspace_url(community, message.to_workspace_id, to: message.created_at.iso8601(6))
      workspace_url(community, message.to_workspace_id, to: message)
    else
      community = respond_to?(:current_community) ? current_community : message.to_community
      # messages_community_url(community, to: message.created_at.iso8601(6))
      messages_community_url(community, to: message)
    end
  end

  def link_to_message(message)
    link_to(format_message_timestamp(message), message_permalink(message))
  end

  def preview_message(message)
    case message
    when Message::Text then preview_message_text(message)
    when Message::Upload then octicon("file") + " " + message.file_name
    when Message::HomeworkUploaded then octicon("file") + " " + message.homework.file_name
    when Message::WorkspacePartnershipCreated then preview_workspace_partnership_created(message)
    end
  end

  def preview_message_text(message)
    I18n.t("discussions.index.you") + ": " + message.text
  end

  def preview_workspace_partnership_created(message)
    if message.workspace_partnership.read_only
      t("messages.workspace_partnership_created.title_reader")
    else
      t("messages.workspace_partnership_created.title_writer")
    end
  end
end
