class CommunityRequestsController < ApplicationController
  layout "public"

  def new
    @form = CommunityRequestForm.new
    @form.community_request = CommunityRequest.new(user: current_user || User.new)
  end

  def create
    @form = CommunityRequestForm.create(community_request: community_request_params, user: current_user || User.new(user_params))
    if @form.result
      redirect_to(root_path, notice: t(".notice"))
    else
      render(:new)
    end
  end

  private

  def community_request_params
    params.require(:community_request).permit(:name, :description, :comment)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
