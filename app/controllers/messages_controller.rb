class MessagesController < ApplicationController
  include RespondMessages

  before_action :authenticate_user
  before_action :must_be_membership
  before_action :must_have_a_subscription

  def create
    @message = Message::Text.create!(message_attributes.merge(from_user: current_user))
    if request.xhr?
      @user = @message.to_user
      @messages = Message.where(id: @message.id) # Force to have an AR relation
      render(layout: false)
    elsif @message.to_user
      redirect_to(messages_path(current_community, user_id: @message.to_user_id))
    elsif @message.to_skill
      redirect_to(messages_skill_path(current_community, @message.to_skill))
    elsif @message.to_workspace
      redirect_to(workspace_path(current_community, @message.to_workspace))
    else
      redirect_to(skills_path(current_community))
    end
  end

  def upload
    message = Message::Upload.create(upload_attributes.merge(from_user: current_user))
    if message.to_community_id
      redirect_to(skills_path(current_community))
    elsif message.to_skill_id
      redirect_to(messages_skill_path(current_community, message.to_skill))
    elsif message.to_workspace_id
      redirect_to(workspace_path(current_community, message.to_workspace))
    else
      redirect_to(messages_path(current_community, user_id: message.to_user_id))
    end
  end

  def update
    @message = Message.from_user(current_user).find(params[:id])
    @message.update!(text: params[:message][:text], edited_at: Time.now.utc)
    render(layout: false)
  end

  def index
    @messages = filter_messages(Message.limit(25))

    if params[:user_id]
      @user = User.find(params[:user_id])
      @messages = @messages.between(current_user, @user)
      Message.from_user(@user).to_user(current_user).unread.update_all(read_at: Time.now)
      @edited_messages = Message.between(current_user, @user).edited_after(1.minute.ago)
    elsif params[:skill_id]
      @subscription.touch(:last_read_at)
      @skill = Skill.find(params[:skill_id])
      @messages = @messages.to_skill(@skill)
      @edited_messages = Message.to_skill(@skill).edited_after(1.minute.ago) if params[:after]
    elsif params[:workspace_id]
      @workspace = Workspace.find(params[:workspace_id])
      @messages = @messages.to_workspace(@workspace)
      @edited_messages = Message.to_workspace(@workspace).edited_after(1.minute.ago) if params[:after]
    else
      current_membership.touch(:last_read_at)
      @messages = @messages.to_community(current_community)
      @edited_messages = Message.to_community(current_community).edited_after(1.minute.ago) if params[:after]
    end

    @skill_ids_with_unread_messages = current_user.subscriptions.with_unread_messages.pluck(:skill_id)

    if request.xhr?
      respond_to do |format|
        format.html { @messages.any? ? render("_list", layout: false) : head(:ok) }
        format.json { render }
      end
    end
  end

  def unread
    message = Message.find(params[:id])
    message.mark_as_unread if current_user.permissions.mark_message_as_unread?(message)
    redirect_to(discussions_path(current_community))
  end

  def pin
    message = Message.find(params[:id])
    message.toggle_pinned_at if message.pinnable_by?(current_user)
    redirect_to(request.referer || "/")
  end

  def vote
    Vote.toggle(current_user, Message.find(params[:id]))
    redirect_to(request.referer || "/")
  end

  def destroy
    message = Message.find(params[:id])
    message.destroy if message.from_user_id == current_user.id || moderator?
    redirect_to(request.referer || "/")
  end

  def download
    message = Message.find(params[:id])
    if message.viewable_by?(current_user)
      message.increment!(:download_count)
      uri = URI.parse(message.file_url)
      uri.path = URI::DEFAULT_PARSER.escape(uri.path)
      redirect_to(uri.to_s, allow_other_host: true)
    else
      render_not_found
    end
  end

  def search
    @text_messages = Message::Text.search(params.merge(community: current_community)).latest
    @file_messages = Message::Upload.search(params.merge(community: current_community)).latest
    render(layout: false)
  end

  def search_form
    render(layout: false)
  end

  private

  def message_attributes
    params.require(:message).permit(:to_user_id, :to_community_id, :to_skill_id, :to_workspace_id, :text)
  end

  def upload_attributes
    params.require(:upload).permit(:to_user_id, :to_community_id, :to_skill_id, :to_workspace_id, :text, :file)
  end

  def must_have_a_subscription
    if (skill_id = (params[:message] ? params[:message][:to_skill_id] : params[:skill_id])).present?
      unless (@subscription = current_user.subscriptions.find_by_skill_id(skill_id))
        request.xhr? ? head(:not_found) : redirect_to(skill_path(current_community, id: skill_id))
      end
    end
  end
end
