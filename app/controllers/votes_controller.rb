class VotesController < ApplicationController
  before_action :find_user

  def index
    @votes = Vote.in_community(current_community).from_user(@user)
  end

  private

  def find_user
    @user = if params[:user_id]
      User.find(params[:user_id])
    else
      current_user
    end
  end
end
