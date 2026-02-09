class Workspace < ActiveRecord::Base
  belongs_to :community
  belongs_to :skill, optional: true
  has_many :partnerships, class_name: "Workspace::Partnership"
  has_many :users, through: :partnerships
  has_many :messages, foreign_key: "to_workspace_id"
  has_many :versions, class_name: "Workspace::Version"

  scope :published, -> { where.not(published_at: nil) }

  def attachment_path
    "#{AwsFileStorage.aws_bucket_prefix}/workspaces/#{id}/attachments/"
  end

  def publish!(to_skill = nil)
    return if published_at?
    update!(published_at: Time.now, skill: to_skill, published_once: true)
    Message::WorkspacePublished.trigger(self)
  end

  def has_readers?
    partnerships.reader.count > 0
  end

  def unpublish!
    return unless published_at?
    update!(published_at: nil)
    Message::WorkspacePublished.untrigger(self)
  end

  def approve!
    return if approved_at?
    update!(approved_at: Time.now)
  end

  def reject!
    return unless rejectable?
    update!(approved_at: nil)
  end

  def rejectable?
    approved_at? && !published_once
  end

  def requires_new_version?
    author_ids = partnerships.writer.pluck(:user_id)
    messages.where("created_at > ? AND from_user_id NOT IN (?)", last_version.created_at, author_ids).any?
  end

  def last_or_new_version
    if requires_new_version?
      new_version(title: title, writing: writing).save!
      yield(last_version) if block_given?
    end
    last_version
  end

  def owner
    users.where("workspace_partnerships.is_owner = TRUE").first
  end

  def owner_id
    users.where("workspace_partnerships.is_owner = TRUE").pluck(:user_id).first
  end

  def writers
    users.where("workspace_partnerships.read_only = FALSE")
  end

  def writing=(value)
    raise NotImplementedError
  end

  def title=(value)
    raise NotImplementedError
  end

  def writing
    last_version.writing
  end

  def title
    last_version.title
  end

  def last_version
    @last_version ||= versions.order(created_at: :desc).first
  end

  def new_version(params)
    version = versions.new(params.merge(number: versions.maximum(:number) + 1))
    @last_version = nil
    version
  end
end
