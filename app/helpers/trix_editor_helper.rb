require "base64"
require "openssl"
require "digest/sha1"

module TrixEditorHelper
  def trix_editor_tag(options)
    @trix_editor = true
    if options[:attachment_path].present?
      config = trix_editor_attachment_config(options[:attachment_path]).to_json
      content_tag("trix-editor", "", options.merge("data-module" => "TrixAttachment", "data-attachment-config" => config))
    else
      content_tag("trix-editor", "", options)
    end
  end

  def include_trix_assets
    if @trix_editor
      [javascript_include_tag("trix"), stylesheet_link_tag("trix", media: "all")].join("\n").html_safe
    end
  end

  def trix_editor_attachment_signature_base64(path)
    policy = trix_editor_attachment_policy_base64(path)
    signature = OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha1"), AwsFileStorage::AWS_BUCKET_URL.password, policy)
    Base64.encode64(signature).delete("\n")
  end

  def trix_editor_attachment_policy_base64(path)
    Base64.encode64({
      expiration: 1.day.from_now.utc.iso8601,
      conditions: [
        {bucket: AwsFileStorage::BUCKET_NAME},
        ["starts-with", "$key", path],
        ["content-length-range", 0, 20.megabytes],
        {acl: "public-read"}
      ]
    }.to_json).delete("\n")
  end

  def trix_editor_attachment_config(path)
    {
      host: File.join(AwsFileStorage::BUCKET_URL, ""),
      AWSAccessKeyId: AwsFileStorage::AWS_BUCKET_URL.user,
      policy: trix_editor_attachment_policy_base64(path),
      signature: trix_editor_attachment_signature_base64(path),
      acl: "public-read",
      key: path
    }
  end
end
