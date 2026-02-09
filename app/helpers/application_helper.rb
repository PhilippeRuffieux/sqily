module ApplicationHelper
  def active_if(bool)
    bool ? "active" : nil
  end

  def current_path?(path)
    request.path.start_with?(path)
  end

  def current_page?(path)
    request.path == path
  end

  def encode_file_path(path)
    "/" + URI::DEFAULT_PARSER.escape(path)
  end

  def encode_file_url(path)
    URI::DEFAULT_PARSER.escape(path)
  end

  def is_current_community_tree_displayable?
    current_community.skills.joins(:prerequisites).exists?
  end

  def inline_css_layout_to_avoid_weird_redraw
    File.read(Rails.root.join("app/assets/stylesheets/layout.css"))
  end

  def page_title
    if @skill
      "#{@skill.name} - #{current_community.name} - Sqily"
    elsif current_community
      "#{current_community.name} - Sqily"
    else
      "Sqily"
    end
  end

  def nl2br(string)
    string.gsub("\n", "<br/>")
  end

  def format_text(text)
    highlight_current_user(nl2br(html_escape(text))).html_safe
  end

  def format_rich_text(text)
    auto_embed(hash_tags_to_links(format_text(text))).html_safe
  end

  def ordered_attribute(order_param, attribute, &block)
    if order_param.none? || order_param.attribute.to_s != attribute.to_s
      block.call(OrderParam.create(attribute), false)
    else
      block.call(order_param.toggle!, true)
    end
  end

  def order_style(order_param, is_currently_sorted)
    is_currently_sorted ? "order-#{order_param.order}" : ""
  end
end
