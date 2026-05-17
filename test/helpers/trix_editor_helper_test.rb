require "test_helper"

class TrixEditorHelperTest < ActiveSupport::TestCase
  include TrixEditorHelper

  def test_attachment_config_uses_sigv4_presigned_post_fields
    config = trix_editor_attachment_config("development/skills/attachments/123/")

    assert_equal(File.join(AwsFileStorage::BUCKET_URL, ""), config[:host])
    assert_equal(config[:host], config[:upload_host])
    assert_equal("public-read", config[:fields]["acl"])
    assert_equal("204", config[:fields]["success_action_status"])
    assert_equal("AWS4-HMAC-SHA256", config[:fields]["x-amz-algorithm"])
    assert_match(%r{\A#{Regexp.escape(AwsFileStorage::AWS_BUCKET_URL.user)}/\d{8}/#{Regexp.escape(AwsFileStorage::BUCKET_REGION)}/s3/aws4_request\z}, config[:fields]["x-amz-credential"])
    assert_match(/\A\d{8}T\d{6}Z\z/, config[:fields]["x-amz-date"])
    assert_match(/\A\h{64}\z/, config[:fields]["x-amz-signature"])
    assert_nil(config[:fields]["AWSAccessKeyId"])
    assert_nil(config[:fields]["signature"])
  end

  def test_attachment_config_policy_allows_key_prefix_and_upload_size
    config = trix_editor_attachment_config("development/skills/attachments/123/")
    policy = JSON.parse(Base64.decode64(config[:fields]["policy"]))

    assert(policy["conditions"].include?({"bucket" => AwsFileStorage::BUCKET_NAME}))
    assert(policy["conditions"].include?(["starts-with", "$key", "development/skills/attachments/123/"]))
    assert(policy["conditions"].include?(["content-length-range", 0, 20.megabytes]))
  end
end
