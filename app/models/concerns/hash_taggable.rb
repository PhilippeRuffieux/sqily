module HashTaggable
  extend ActiveSupport::Concern

  included do
    has_many :hash_tags, as: :taggable

    scope :by_hash_tags, ->(names) {
      return if names.blank?
      names = Array(names).map { |str| HashTag.normalize(str) }
      joins(:hash_tags).where("hash_tags.name IN (?)", names)
    }
  end

  module ClassMethods
    def watch_hash_tags_on(attributes)
      after_create { HashTag.index_record_attributes(self, attributes) }
    end
  end
end
