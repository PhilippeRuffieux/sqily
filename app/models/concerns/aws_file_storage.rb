module AwsFileStorage
  extend ActiveSupport::Concern

  AWS_BUCKET_URL = URI.parse(ENV["AWS_BUCKET_URL"])
  BUCKET_REGION = AWS_BUCKET_URL.host.split(".")[0].delete_prefix("s3-")
  BUCKET_NAME = AWS_BUCKET_URL.path.delete_prefix("/")

  bucket_uri = AWS_BUCKET_URL.dup
  bucket_uri.user = bucket_uri.password = nil
  bucket_url = bucket_uri.to_s
  bucket_url += "/" if bucket_url.ends_with?("/")
  BUCKET_URL = bucket_url

  Aws.config.update(region: BUCKET_REGION, credentials: Aws::Credentials.new(AWS_BUCKET_URL.user, AWS_BUCKET_URL.password))

  included do
    after_save :save_file
    attr_reader :file
  end

  def self.aws_bucket_prefix
    ENV.fetch("AWS_BUCKET_PREFIX") { Rails.env.to_s }
  end

  def file_name
    File.basename(file_node) if file_node
  end

  def file_path
    File.join(AwsFileStorage.aws_bucket_prefix, self.class.table_name, file_node) if file_node
  end

  def file_url
    File.join(BUCKET_URL, file_path) if file_path
  end

  def file=(pathname_or_uploaded_file)
    if pathname_or_uploaded_file
      hex = SecureRandom.hex(16)
      @file = pathname_or_uploaded_file
      original_filename = file.respond_to?(:original_filename) ? file.original_filename : file.basename
      self.file_node = File.join(hex[0..1], hex[2..3], hex[4..], original_filename)
    else
      self.file_node = nil
    end
  end

  def save_file
    if file
      data = file.is_a?(Pathname) ? file.read : file
      # TODO: content_type
      headers = {acl: "public-read", cache_control: "public, max-age=2592000"}
      bucket.put_object(headers.merge(key: file_path, body: data))
    end
  end

  def file_system_path
    Rails.root.join("public/storage".freeze, self.class.table_name, file_node) if file_node
  end

  # Homework.find_each { |m| m.extend(AwsFileStorage); m.migrate_file_to_s3 }
  def migrate_file_to_s3
    return unless file_system_path&.exist?
    @file = file_system_path.read
    save_file
  end

  def bucket
    @bucket ||= Aws::S3::Resource.new.bucket(BUCKET_NAME)
  end
end
