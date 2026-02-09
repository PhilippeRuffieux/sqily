class OrderParam
  attr_reader :attribute
  attr_reader :order

  def none?
    !(@attribute.present? && @order.present?)
  end

  def toggle!
    new_order = (@order == :asc) ? :desc : :asc
    OrderParam.new(@attribute, new_order)
  end

  def self.create(attribute)
    OrderParam.new(attribute, :asc)
  end

  private

  def initialize(attribute, order)
    @attribute = attribute&.to_sym
    @order = order&.to_sym
  end

  class Parser
    SUPPORTED_ORDERS = %i[asc desc]

    def initialize
      @permitted_attributes = []
    end

    def permit(permitted_attributes)
      @permitted_attributes = permitted_attributes
      self
    end

    def parse(raw_order_param)
      attribute, order = Formatter.parse(raw_order_param)

      order = nil if order.blank? || !SUPPORTED_ORDERS.include?(order.to_sym)
      attribute = nil if attribute.blank? || !@permitted_attributes.include?(attribute.to_sym)

      OrderParam.new(attribute, order)
    end

    def unsafe_parse(raw_order_param)
      attribute, order = Formatter.parse(raw_order_param)

      order = nil if order.blank? || !SUPPORTED_ORDERS.include?(order.to_sym)
      attribute = nil if attribute.blank?

      OrderParam.new(attribute, order)
    end
  end

  class Formatter
    def self.parse(raw_order_param)
      raw_order_param.blank? ? [nil, nil] : raw_order_param.split(":")
    end

    def self.to_s(order_param)
      "#{order_param.attribute}:#{order_param.order}"
    end

    def self.to_default_s(attribute)
      "#{attribute}:asc"
    end
  end
end
