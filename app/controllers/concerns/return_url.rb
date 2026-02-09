module ReturnUrl
  extend ActiveSupport::Concern

  included do
    helper_method :return_url
    helper_method :return_url_hidden_field_tag
  end

  def return_url
    params[:return_url] || request.referer || skills_path(current_community)
  end

  def redirect_to_return_url
    redirect_to(return_url)
  end

  def return_url_hidden_field_tag
    view_context.hidden_field_tag(:return_url, return_url)
  end
end
