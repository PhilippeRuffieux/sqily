class HashTag < ActiveRecord::Base
  belongs_to :taggable, polymorphic: true
  belongs_to :message, foreign_key: :taggable_id

  validates_presence_of :name, :taggable_id, :taggable_type

  scope :most_popular, -> { group(:name).select("name, COUNT(*)").order("COUNT(*) DESC") }

  def self.watch_model_attributes(model, attributes)
    model.after_create { HashTag.index_record_attributes(self, attributes) }
  end

  def self.index_record_attributes(record, attributes)
    string = Array(attributes).reduce("") { |str, attr| record.public_send(attr) }
    record.hash_tags.where.not(name: names = extract(string)).delete_all
    names.each { |name| record.hash_tags.create!(name: name) if !record.hash_tags.where(name: name).exists? }
  end

  def self.split(string)
    return [] unless string
    array = string.split("#")[1..]
    array ? array.map { |str| str.split(/\b/).first }.delete_if { |str| !str.match(/\b/) } : []
  end

  def self.extract(string)
    split(string).map { |str| normalize(str) }
  end

  def self.normalize(string)
    string.unaccent.downcase
  end

  def self.search(query)
    if query
      query[0] = "" if query[0] == "#"
      where("name LIKE ?", normalize(query) + "%")
    else
      all
    end
  end

  def self.pluck_name
    pluck(Arel.sql("DISTINCT name"))
  end
end
