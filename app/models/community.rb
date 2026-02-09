class Community < ActiveRecord::Base
  TypeScopes.inject self
  include SafeOrder

  validates_presence_of :name, :permalink
  validates_uniqueness_of :permalink

  has_many :messages, foreign_key: "to_community_id"
  has_many :skills
  has_many :published_skills, -> { where.not(published_at: nil) }, class_name: "Skill"
  has_many :memberships
  has_many :teams
  has_many :invitations
  has_many :users, through: :memberships
  has_many :invitation_requests
  has_many :events

  scope :order_by_created_at, ->(order) { order(created_at: order) }
  scope :order_by_last_page_viewed_at, ->(direction) { safe_order("(SELECT MAX(page_views.created_at) FROM memberships JOIN page_views ON page_views.membership_id = memberships.id WHERE memberships.community_id = communities.id)", direction, nulls: :last) }
  scope :order_by_page_views, ->(direction) { safe_order("(SELECT COUNT(*) FROM memberships JOIN page_views ON page_views.membership_id = memberships.id WHERE memberships.community_id = communities.id)", direction) }
  scope :order_by_users, ->(direction) { safe_order("(SELECT COUNT(*) FROM memberships WHERE memberships.community_id = communities.id)", direction) }
  scope :order_by_skills, ->(direction) { safe_order("(SELECT COUNT(*) FROM skills WHERE skills.community_id = communities.id)", direction) }
  scope :order_by_expertises, ->(direction) { safe_order("(SELECT COUNT(*) FROM subscriptions JOIN skills ON subscriptions.skill_id = skills.id AND skills.community_id = communities.id WHERE subscriptions.completed_at IS NOT NULL)", direction) }
  scope :order_by_evaluations, ->(direction) { safe_order("(SELECT COUNT(*) FROM evaluations WHERE evaluations.skill_id IN (SELECT id FROM skills WHERE skills.community_id = communities.id AND skills.published_at IS NOT NULL))", direction) }
  scope :order_by_evaluation_feedbacks, ->(direction) { safe_order("(SELECT COUNT(*) FROM messages JOIN homeworks ON messages.homework_id = homeworks.id AND messages.type = 'Message::HomeworkUploaded' AND messages.text IS NOT NULL JOIN evaluations ON homeworks.evaluation_id = evaluations.id AND evaluations.skill_id IN (SELECT id FROM skills WHERE skills.community_id = communities.id))", direction) }
  scope :order_by_uploads, ->(direction) { safe_order("(SELECT COUNT(*) FROM messages WHERE messages.type = 'Message::Upload' AND (messages.to_community_id = communities.id OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = communities.id)))", direction) }
  scope :order_by_workspaces, ->(direction) { safe_order("(SELECT COUNT(*) FROM workspaces WHERE workspaces.community_id = communities.id)", direction) }
  scope :order_by_events, ->(direction) { safe_order("(SELECT COUNT(*) FROM events WHERE events.community_id = communities.id)", direction) }
  scope :order_by_hashtags, ->(direction) { safe_order("(SELECT COUNT(*) FROM messages JOIN hash_tags ON hash_tags.taggable_type = 'Message' AND hash_tags.taggable_id = messages.id WHERE messages.to_community_id = communities.id OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = communities.id))", direction) }
  scope :order_by_messages, ->(direction) { safe_order("(SELECT COUNT(*) FROM messages WHERE messages.type = 'Message::Text' AND (messages.to_community_id = communities.id OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = communities.id)))", direction) }
  scope :order_by_pinned_messages, ->(direction) { safe_order("(SELECT COUNT(*) FROM messages WHERE messages.pinned_at IS NOT NULL AND (messages.to_community_id = communities.id OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = communities.id)))", direction) }
  scope :order_by_votes, ->(direction) { safe_order("(SELECT COUNT(*) FROM votes JOIN messages ON messages.id = votes.message_id AND (messages.to_community_id = communities.id OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = communities.id)) AND messages.deleted_at IS NULL)", direction) }

  def self.suggest_unique_permalink(permalink)
    permalink += rand(9).to_s while Community.where(permalink: permalink).exists?
    permalink
  end

  def self.filter_by(params)
    scope = all
    scope = scope.name_contains(params[:name], sensitive: false) if params[:name].present?
    scope
  end

  def self.order_by(value)
    case value
    when "users" then order_by_users(:desc)
    when "skills" then order_by_skills(:desc)
    when "last_activity" then order_by_last_page_viewed_at(:desc)
    else all
    end
  end

  def name=(string)
    write_attribute(:name, string)
    self.permalink ||= string&.parameterize
  end

  def add_user_by_email(email)
    if (user = User.find_by_email(email.downcase))
      add_user(user)
    else
      Invitation.find_or_create(self, email)
    end
  end

  def add_user(user)
    memberships.find_by_user_id(user.id) || memberships.create!(user: user)
  end

  def add_moderator(user)
    membership = add_user(user)
    membership.update(moderator: true)
    membership
  end

  def remove_user(user)
    if (membership = memberships.find_by_user_id(user.id))
      Subscription.where(user_id: user.id, skill_id: skills.pluck(:id)).each do |subscription|
        subscription.homeworks.each(&:destroy)
        subscription.exams.each(&:destroy)
        subscription.destroy
      end
      membership.destroy
    end
  end

  def to_param
    permalink
  end

  def statistics
    @statistics ||= Statistics.new(self)
  end

  # Cache Community#memberships.count which is heavily used in skill list
  def membership_count
    @membership_count ||= memberships.count
  end
end
