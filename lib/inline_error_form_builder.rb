class InlineErrorFormBuilder < ActionView::Helpers::FormBuilder
  def label(field, text = object.class.human_attribute_name(field))
    if (error = object.errors[field].first)
      super(field, text.to_s + " " + error)
    else
      super
    end
  end
end
