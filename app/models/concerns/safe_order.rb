module SafeOrder
  extend ActiveSupport::Concern

  ORDER_DIRECTION = [:asc, :desc, :ASC, :DESC, "asc", "desc", "ASC", "DESC"].freeze
  NULLS_DIRECTIONS = [:first, :last, :FIRST, :LAST, "first", "last", "FIRST", "LAST"].freeze

  class_methods do
    def safe_order(sql_or_array, direction = nil, nulls: nil)
      parts = sql_or_array.is_a?(Array) ? [sanitize_sql(sql_or_array)] : [sql_or_array]
      parts << direction if direction && ORDER_DIRECTION.include?(direction)
      parts << sanitize_sql_for_order(["NULLS #{nulls}"]) if nulls && NULLS_DIRECTIONS.include?(nulls)
      order(Arel.sql(parts.join(" ")))
    end
  end
end
