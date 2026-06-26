require "test_helper"

class AwsFileStorageTest < ActiveSupport::TestCase
  def test_build_bucket_config_for_aws_hosted_s3
    config = AwsFileStorage.build_bucket_config("https://key:secret@s3-eu-central-1.amazonaws.com/sqily-dev")

    assert_equal("sqily-dev", config.bucket_name)
    assert_equal("eu-central-1", config.bucket_region)
    assert_equal("https://s3-eu-central-1.amazonaws.com/sqily-dev", config.bucket_url)
    assert_nil(config.client_options[:endpoint])
    assert_nil(config.client_options[:force_path_style])
  end

  def test_build_bucket_config_for_local_s3_endpoint
    config = AwsFileStorage.build_bucket_config("http://minio:minio@127.0.0.1:9000/sqily-test?region=us-east-1&path_style=true")

    assert_equal("sqily-test", config.bucket_name)
    assert_equal("us-east-1", config.bucket_region)
    assert_equal("http://127.0.0.1:9000/sqily-test", config.bucket_url)
    assert_equal("http://127.0.0.1:9000", config.client_options[:endpoint])
    assert_equal(true, config.client_options[:force_path_style])
  end

  def test_build_bucket_config_with_public_bucket_url_override
    config = AwsFileStorage.build_bucket_config(
      "http://minioadmin:minioadmin@host.docker.internal:9000/sqily-development?region=us-east-1&path_style=true",
      "http://127.0.0.1:9000/sqily-development"
    )

    assert_equal("sqily-development", config.bucket_name)
    assert_equal("http://127.0.0.1:9000/sqily-development", config.bucket_url)
    assert_equal("http://host.docker.internal:9000", config.client_options[:endpoint])
  end
end
