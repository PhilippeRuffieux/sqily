module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  def current_user
    if (session_token = cookies.signed[:session_token])
      @current_user ||= User.find_by_id(session_token)
    end
  end

  def current_user=(user)
    cookies.permanent.signed[:session_token] = user.try(:id)
  end

  def current_user_must_be_admin
    redirect_to("/") if !current_user || !current_user.admin?
  end

  def set_current_user_locale
    I18n.locale = current_user.locale if current_user
  end
end
