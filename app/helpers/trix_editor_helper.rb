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

  def trix_editor_attachment_presigned_post(path)
    Aws::S3::Resource.new.bucket(AwsFileStorage::BUCKET_NAME).presigned_post(
      key_starts_with: path,
      acl: "public-read",
      success_action_status: "204",
      content_length_range: 0..20.megabytes,
      expires: 1.day.from_now
    )
  end

  def trix_editor_attachment_config(path)
    presigned_post = trix_editor_attachment_presigned_post(path)
    public_host = File.join(AwsFileStorage::BUCKET_URL, "")

    {
      upload_host: public_host,
      host: public_host,
      fields: presigned_post.fields,
      key: path
    }
  end
end
