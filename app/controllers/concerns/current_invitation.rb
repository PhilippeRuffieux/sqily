module CurrentInvitation
  extend ActiveSupport::Concern

  included do
    helper_method :current_invitation
  end

  def current_invitation
    if (token = cookies.signed[:invitation_token])
      @current_invitation ||= Invitation.find_by_token(token)
    end
  end

  def current_invitation=(invitation)
    cookies.permanent.signed[:invitation_token] = invitation.try(:token)
  end
end
