class SessionsController < ApplicationController
  before_action :redirect_user_to_most_relevant_community, only: %i[show create]

  layout "public"

  def show
  end

  def create
    if (self.current_user = User.authenticate(params[:email], params[:password]))
      if current_invitation.try(:complete, current_user)
        redirect_to(skills_path(current_invitation.community))
        self.current_invitation = nil
      else
        redirect_user_to_most_relevant_community
      end
    else
      @login_failed = true
      render(:show)
    end
  end

  def destroy
    self.current_user = nil
    redirect_to("/")
  end
end
