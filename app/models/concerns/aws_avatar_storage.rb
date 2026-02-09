module AwsAvatarStorage
  extend ActiveSupport::Concern

  AVATAR_SIZE = 200

  included do
    after_save :save_avatar
    attr_reader :avatar
  end

  def avatar_path
    if avatar_name
      File.join(AwsFileStorage.aws_bucket_prefix, self.class.table_name, avatar_name[0..1], avatar_name[2..3], avatar_name[4..])
    end
  end

  def avatar_url
    File.join(AwsFileStorage::BUCKET_URL, avatar_path) if avatar_path
  end

  def avatar_system_path
    if avatar_name
      path = File.join("storage", self.class.table_name, "avatars", avatar_name[0..1], avatar_name[2..3], avatar_name[4..])
      Rails.root.join("public", path)
    end
  end

  def avatar=(pathname_or_uploaded_file)
    @avatar = pathname_or_uploaded_file
    self.avatar_name = SecureRandom.hex(40) + ".jpg"
  end

  def delete_avatar
    path = avatar_path
    update_attribute(:avatar_name, @avatar = nil)
    bucket.object(path).delete
  end

  def save_avatar
    if avatar
      headers = {acl: "public-read", cache_control: "public, max-age=2592000"}
      bucket.put_object(headers.merge(key: avatar_path, body: resize_picture(avatar.read, AVATAR_SIZE)))
    end
  end

  def resize_picture(data, size)
    picture = Magick::Image.from_blob(data).first
    # Crop picture if not a square
    if (min_size = [picture.rows, picture.columns].min) >= AVATAR_SIZE
      picture.crop!(Magick::CenterGravity, min_size, min_size)
    end
    picture.resize_to_fill!(size, size)
    normalize_picture(picture)
  ensure
    picture&.destroy!
  end

  def normalize_picture(picture)
    picture.colorspace = Magick::SRGBColorspace
    picture = picture.auto_level_channel.strip!  # Improve colors and remove profiles to save weight.
    picture.to_blob { |img|
      img.format = "JPEG".freeze
      img.quality = 80
      img.interlace = Magick::LineInterlace
    }
  ensure
    picture&.destroy!
  end

  # User.where("avatar_name IS NOT NULL").find_each { |m| m.extend(AwsAvatarStorage); m.migrate_file_to_s3 }
  def migrate_file_to_s3
    return if !avatar_system_path || !avatar_system_path.exist?
    @avatar = avatar_system_path
    save_avatar
  end

  def bucket
    @bucket ||= Aws::S3::Resource.new.bucket(AwsFileStorage::BUCKET_NAME)
  end
end
