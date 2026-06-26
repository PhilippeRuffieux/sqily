module AwsFileStorage
  extend ActiveSupport::Concern

  BucketConfig = Struct.new(:bucket_uri, :bucket_name, :bucket_region, :bucket_url, :client_options, keyword_init: true)

  def self.build_bucket_config(bucket_url, public_bucket_url = nil)
    bucket_uri = URI.parse(bucket_url)
    query = Rack::Utils.parse_nested_query(bucket_uri.query)
    aws_hosted = bucket_uri.host&.match?(/\As3(?:[.-][a-z0-9-]+)?\.amazonaws\.com\z/)

    public_bucket_uri = if public_bucket_url.present?
      URI.parse(public_bucket_url)
    else
      bucket_uri.dup.tap do |uri|
        uri.user = uri.password = nil
        uri.query = uri.fragment = nil
      end
    end

    client_options = {
      region: query["region"] || infer_region(bucket_uri.host) || "us-east-1",
      credentials: Aws::Credentials.new(bucket_uri.user, bucket_uri.password),
      signature_version: "v4"
    }

    unless aws_hosted
      endpoint_uri = bucket_uri.dup
      endpoint_uri.user = endpoint_uri.password = nil
      endpoint_uri.path = ""
      endpoint_uri.query = endpoint_uri.fragment = nil
      client_options[:endpoint] = endpoint_uri.to_s
      client_options[:force_path_style] = (query["path_style"] != "false")
    end

    BucketConfig.new(
      bucket_uri:,
      bucket_name: bucket_uri.path.delete_prefix("/"),
      bucket_region: client_options[:region],
      bucket_url: public_bucket_uri.to_s,
      client_options:
    )
  end

  def self.infer_region(host)
    return "us-east-1" if host == "s3.amazonaws.com"

    host&.match(/\As3[.-]([a-z0-9-]+)\.amazonaws\.com\z/)&.captures&.first
  end

  CONFIG = build_bucket_config(ENV.fetch("AWS_BUCKET_URL"), ENV["MINIO_PUBLIC_BUCKET_URL"].presence)
  AWS_BUCKET_URL = CONFIG.bucket_uri
  BUCKET_REGION = CONFIG.bucket_region
  BUCKET_NAME = CONFIG.bucket_name
  BUCKET_URL = CONFIG.bucket_url

  Aws.config.update(**CONFIG.client_options)

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
