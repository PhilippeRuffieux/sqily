class Workspace::Partnership < ActiveRecord::Base
  belongs_to :workspace
  belongs_to :user

  scope :reader, -> { where(read_only: true) }
  scope :writer, -> { where(read_only: false) }

  def unread?
    !read_at || read_at < workspace.updated_at
  end
end
