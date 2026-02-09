module StatisticsHelper
  def ordered_statistics_path(name, order_param)
    url_order_param = OrderParam::Formatter.to_s(order_param)
    link_to(name, statistics_path(order: url_order_param))
  end
end
