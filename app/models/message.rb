class Message < ActiveRecord::Base
  TypeScopes.inject self

  belongs_to :from_user, class_name: "User", optional: true
  belongs_to :from_user, class_name: "User", optional: true
  belongs_to :to_user, class_name: "User", optional: true
  belongs_to :to_skill, class_name: "Skill", optional: true
  belongs_to :to_community, class_name: "Community", optional: true
  belongs_to :to_workspace, class_name: "Workspace", optional: true

  has_many :votes
  has_many :hash_tags, as: :taggable

  include HashTaggable

  watch_hash_tags_on :text

  validate :validate_users_are_different
  validate :validates_presence_of_a_recipient
  validates_presence_of :from_user, if: :from_user_required?

  scope :oldest, -> { order(:id) }
  scope :latest, -> { order("messages.id DESC") }
  scope :unread, -> { where(read_at: nil) }
  scope :to_user, ->(user) { where(to_user_id: user.id) }
  scope :from_user, ->(user) { where(from_user_id: user) }
  scope :to_skill, ->(skill) { where(to_skill_id: skill) }
  scope :to_community, ->(community) { where(to_community_id: community) }
  scope :to_workspace, ->(workspace) { where(to_workspace_id: workspace) }
  scope :before, ->(id) { id ? where("id < ?", id) : all }
  scope :after, ->(id) { id ? where("id > ?", id) : all }
  scope :pinned, -> { where.not(pinned_at: nil) }
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :created_before, ->(timestamp) { where("messages.created_at < ?", timestamp) }
  scope :created_between, ->(from, to) { where("messages.created_at BETWEEN ? AND ?", from, to) }
  scope :edited_after, ->(date) { where("edited_at > ?", date) }
  scope :voted_by, ->(user) { joins(:votes).where("votes.user_id = ?", user) }

  scope :text_search, ->(query) {
    where(%{to_tsvector("text") @@ plainto_tsquery(?) OR file_node ILIKE ?}.freeze, query, "%#{query}%")
  }

  scope :between, ->(user1, user2) {
    where(from_user_id: [user1, user2], to_user_id: [user1, user2])
  }

  scope :in_community, ->(community) {
    skill_ids = community.skills.pluck(:id)
    where("messages.to_community_id = ? OR messages.to_skill_id IN (?)", community, skill_ids)
  }

  scope :latest_discussions_to, ->(user) {
    where(to_user: user).order("created_at DESC")
      .where("messages.id = (SELECT MAX(msg2.id) FROM messages msg2 WHERE msg2.to_user_id = ? AND msg2.from_user_id = messages.from_user_id)", user)
  }

  scope :unread_user_ids_to, ->(user, community) {
    unread.to_user(user).from_a_member_of(community).pluck(:from_user_id).uniq
  }

  scope :from_a_member_of, ->(community) {
    joins("JOIN memberships ON memberships.user_id = messages.from_user_id")
      .where("memberships.community_id = ?", community)
  }

  scope :with_votes, -> { where("(SELECT COUNT(*) FROM votes WHERE votes.message_id = messages.id) > 0") }

  #####################
  ### Class methods ###
  #####################

  def self.search(params)
    scope = all
    scope = scope.text_search(params[:query]) if params[:query]
    scope = scope.in_community(params[:community]) if params[:community]
    scope
  end

  ######################
  ### Public methods ###
  ######################

  def toggle_pinned_at
    update(pinned_at: pinned_at ? nil : Time.now)
    pinned_at
  end

  def pinnable_by?(user)
    return false if to_user_id
    if to_community_id
      user.memberships.where(community_id: to_community_id).pluck(:moderator).first
    elsif to_skill_id
      user.subscriptions.where(skill_id: to_skill_id).pluck(:completed_at).first ||
        user.memberships.where(community_id: to_skill.community_id).pluck(:moderator).first
    end
  end

  def toggle_deleted_at
    update(deleted_at: deleted_at ? nil : Time.now)
  end

  def viewable_by?(user)
    return true if from_user_id == user.id
    if to_user_id
      to_user_id == user.id
    elsif to_community_id
      user.memberships.where(community_id: to_community_id).exists?
    elsif to_skill_id
      user.subscriptions.where(skill_id: to_skill_id).exists?
    elsif to_workspace_id
      user.workspace_partnerships.where(workspace_id: to_workspace_id).exists? || to_workspace.published_at?
    end
  end

  def community
    if to_community_id
      to_community
    elsif to_skill_id
      to_skill.community
    elsif to_workspace_id
      to_workspace.community
    end
  end

  def mark_as_unread
    update(read_at: read_at ? nil : Time.now)
  end

  private

  def validate_users_are_different
    errors.add(:to_user, :invalid) if from_user_id && from_user_id == to_user_id
  end

  def validates_presence_of_a_recipient
    errors.add(:to_user, :not_blank) if !to_user_id && !to_community_id && !to_skill_id && !to_workspace_id
  end

  def from_user_required?
    true
  end
end
