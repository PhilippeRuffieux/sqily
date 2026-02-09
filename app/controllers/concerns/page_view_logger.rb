module PageViewLogger
  extend ActiveSupport::Concern

  included do
    before_action :log_page_view
  end

  def log_page_view
    return if request.xhr?
    return if !current_membership
    PageView.create!(
      membership: current_membership,
      ip_address: request.remote_ip,
      method: request.method,
      controller: controller_name,
      action: action_name,
      # params: params.permit!.to_h,
      path: request.path,
      referer: request.referer
    )
  end
end
