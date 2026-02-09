module Admin::CommunitiesHelper
  def ordered_admin_statistics_path(name, order_param)
    url_order_param = OrderParam::Formatter.to_s(order_param)
    link_to(name, statistics_admin_communities_path(order: url_order_param))
  end

  def link_to_order_by(label, value)
    if params[:order_by] == value
      label + " ↓"
    else
      link_to(label, url_for(params.to_unsafe_hash.merge(order_by: value)))
    end
  end
end
