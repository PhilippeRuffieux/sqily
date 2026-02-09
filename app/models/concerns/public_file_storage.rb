module PublicFileStorage
  extend ActiveSupport::Concern

  included do
    after_save :save_file
    attr_reader :file
  end

  def file_name
    File.basename(file_node)
  end

  def file_path
    File.join("storage".freeze, self.class.table_name, file_node) if file_node
  end

  def file_url
    "/" + file_path
  end

  def file_system_path
    Rails.root.join("public", file_path)
  end

  def file=(pathname_or_uploaded_file)
    hex = SecureRandom.hex(16)
    @file = pathname_or_uploaded_file
    original_filename = file.respond_to?(:original_filename) ? file.original_filename : file.basename
    self.file_node = File.join(hex[0..1], hex[2..3], hex[4..], original_filename)
  end

  def save_file
    if file
      file_system_path.dirname.mkpath
      file_system_path.binwrite(file.read)
    end
  end
end
