class Page < ApplicationRecord
  validates_presence_of :slug
  validates_uniqueness_of :slug

  def attachment_path
    "#{AwsFileStorage.aws_bucket_prefix}/pages/#{id}/attachments/"
  end

  def slug=(value)
    write_attribute(:slug, value&.parameterize)
  end
end
