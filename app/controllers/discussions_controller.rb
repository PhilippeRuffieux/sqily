class DiscussionsController < ApplicationController
  before_action :authenticate_user
  before_action :must_be_membership

  def index
    @messages = Message.latest_discussions_to(current_user).from_a_member_of(current_community).page(params[:page])
    @unread_user_ids = Message.unread_user_ids_to(current_user, current_community)
  end
end
