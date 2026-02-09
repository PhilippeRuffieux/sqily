class User < ActiveRecord::Base
  include AwsAvatarStorage
  include SafeOrder

  TypeScopes.inject self

  validates_uniqueness_of :email
  validates_presence_of :email, :name
  validates_length_of :name, maximum: 32
  validates :email, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/, if: :email
  validates_inclusion_of :locale, in: %w[fr-CH de-CH it-CH en]

  has_secure_password

  has_many :memberships
  has_many :communities, through: :memberships
  has_many :votes
  has_many :participations

  has_many :subscriptions
  has_many :skills, through: :subscriptions
  has_many :homeworks, through: :subscriptions

  has_many :workspace_partnerships, class_name: "Workspace::Partnership"
  has_many :workspaces, through: :workspace_partnerships

  scope :daily_summary, -> { where(daily_summary: true) }
  scope :with_unread_messages_to, ->(user) { where("(SELECT COUNT(*) FROM messages WHERE from_user_id = users.id AND to_user_id = ? AND read_at IS NULL) > 0", user.id) }
  scope :search_by_name, ->(query) { name_contains(query, sensitive: false) }
  scope :in_community, ->(community) { joins(:memberships).where(memberships: {community: community}) }
  scope :active, -> { where("last_activity_at > ?", 10.seconds.ago) }

  scope :by_team, ->(team) { merge(Membership.by_team(team)) }

  scope :order_by_name, -> { order(:name) }

  scope :order_by_last_message, ->(user) { order(Arel.sql("(SELECT MAX(messages.id) FROM messages WHERE from_user_id = users.id AND to_user_id = #{user.id}) DESC NULLS LAST")) }

  scope :order_by_skill_ranking, ->(skill) {
    order(Arel.sql("(SELECT COUNT(*) FROM messages, votes WHERE from_user_id = users.id AND to_skill_id = #{skill.id} AND votes.message_id = messages.id) DESC"))
      .order(Arel.sql("(SELECT COUNT(*) FROM messages WHERE from_user_id = users.id AND to_skill_id = #{skill.id} AND pinned_at IS NOT NULL) DESC"))
      .order(Arel.sql("(SELECT COUNT(*) FROM messages WHERE from_user_id = users.id AND to_skill_id = #{skill.id}) DESC"))
  }

  scope :order_by_community_ranking, ->(community) {
    order(Arel.sql("(SELECT COUNT(*) FROM messages, votes WHERE from_user_id = users.id AND to_community_id = #{community.id} AND votes.message_id = messages.id) DESC"))
      .order(Arel.sql("(SELECT COUNT(*) FROM messages WHERE from_user_id = users.id AND to_community_id = #{community.id} AND pinned_at IS NOT NULL) DESC"))
      .order(Arel.sql("(SELECT COUNT(*) FROM subscriptions, skills WHERE skills.community_id = #{community.id} AND subscriptions.skill_id = skills.id AND " \
      "subscriptions.user_id = users.id AND subscriptions.completed_at IS NOT NULL) DESC"))
  }

  scope :order_by_last_page_viewed_at, ->(community, direction) { safe_order("(SELECT MAX(page_views.created_at) FROM memberships JOIN page_views ON page_views.membership_id = memberships.id WHERE memberships.user_id = users.id AND memberships.community_id = #{community.id})", direction) }
  scope :order_by_page_views, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM memberships JOIN page_views ON page_views.membership_id = memberships.id WHERE memberships.user_id = users.id AND memberships.community_id = #{community.id})", direction) }
  scope :order_by_messages, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM messages WHERE messages.from_user_id = users.id AND messages.type = 'Message::Text' AND (messages.to_community_id = #{community.id} OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = #{community.id})))", direction) }
  scope :order_by_pinned_messages, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM messages WHERE messages.from_user_id = users.id AND messages.pinned_at IS NOT NULL AND (messages.to_community_id = #{community.id} OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = #{community.id})))", direction) }
  scope :order_by_event_participations, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM participations JOIN events ON participations.event_id = events.id AND (events.community_id = #{community.id} OR events.skill_id IN (SELECT id FROM skills WHERE skills.community_id = #{community.id})) WHERE participations.user_id = users.id)", direction) }
  scope :order_by_received_votes, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM votes JOIN messages ON messages.id = votes.message_id AND (messages.to_community_id = #{community.id} OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = #{community.id})) AND messages.deleted_at IS NULL AND messages.from_user_id = users.id)", direction) }
  scope :order_by_uploads, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM messages WHERE messages.from_user_id = users.id AND messages.type = 'Message::Upload' AND (messages.to_community_id = #{community.id} OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = #{community.id})))", direction) }
  scope :order_by_useful_uploads, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM messages WHERE messages.from_user_id = users.id AND messages.type = 'Message::Upload' AND (SELECT COUNT(*) FROM votes WHERE votes.message_id = messages.id) > 0 AND (messages.to_community_id = #{community.id} OR messages.to_skill_id IN (SELECT id FROM skills WHERE skills.community_id = #{community.id})))", direction) }
  scope :order_by_created_skills, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM skills WHERE skills.community_id = #{community.id} AND skills.creator_id = users.id)", direction) }
  scope :order_by_completed_skills, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM subscriptions JOIN skills ON subscriptions.skill_id = skills.id AND skills.community_id = #{community.id} WHERE subscriptions.user_id = users.id AND subscriptions.completed_at IS NOT NULL AND subscriptions.validator_id IS NOT NULL)", direction) }
  scope :order_by_evaluations, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM evaluations WHERE evaluations.user_id = users.id AND evaluations.skill_id IN (SELECT id FROM skills WHERE skills.community_id = #{community.id} AND skills.published_at IS NOT NULL) AND id = (SELECT MAX(id) FROM evaluations as e WHERE e.user_id = evaluations.user_id AND e.skill_id = evaluations.skill_id))", direction) }
  scope :order_by_evaluation_feedbacks, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM messages JOIN homeworks ON messages.homework_id = homeworks.id AND messages.to_user_id = users.id AND messages.type = 'Message::HomeworkUploaded' AND messages.text IS NOT NULL JOIN evaluations ON homeworks.evaluation_id = evaluations.id AND evaluations.skill_id IN (SELECT id FROM skills WHERE skills.community_id = #{community.id}))", direction) }
  scope :order_by_expert_validations, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM subscriptions JOIN skills ON subscriptions.skill_id = skills.id AND skills.community_id = #{community.id} WHERE subscriptions.validator_id = users.id)", direction) }
  scope :order_by_published_workspaces, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM workspace_partnerships JOIN workspaces ON workspace_partnerships.workspace_id = workspaces.id AND workspaces.community_id = #{community.id} AND workspaces.published_at IS NOT NULL WHERE workspace_partnerships.user_id = users.id AND workspace_partnerships.read_only IS FALSE)", direction) }
  scope :order_by_workspace_feedbacks, ->(community, direction) { safe_order("(SELECT COUNT(*) FROM messages JOIN workspaces ON messages.to_workspace_id = workspaces.id AND workspaces.community_id = #{community.id} WHERE messages.from_user_id = users.id AND messages.type = 'Message::Text')", direction) }

  def self.downcase_emails
    User.update_all("email = lower(email)")
  end

  def self.emails_with_upcase
    where("email != lower(email)")
  end

  def self.lowered_duplicated_emails
    group("lower(email)").having("count(*) > 1").order("count(*)").pluck("lower(email)")
  end

  def self.duplicated_emails
    where("lower(email) IN (?)", lowered_duplicated_emails)
  end

  def self.authenticate(email, password)
    User.find_by_email(email.downcase).try(:authenticate, password)
  end

  def self.signup(attributes, invitation = nil)
    if (user = User.new(attributes)) && user.save
      invitation&.complete(user)
    end
    user
  end

  def owns_workspace?(workspace)
    workspace.owner_id == id
  end

  def membership_for(community)
    memberships.where(community_id: community.id).first
  end

  def touch_last_activity_at
    touch(:last_activity_at)
  end

  def latest_chatters
    User.where(id: Message.where(to_user: self).pluck("DISTINCT from_user_id"))
  end

  def owned_workspaces
    workspaces.where(workspace_partnerships: {is_owner: true})
  end

  def email=(value)
    write_attribute(:email, value && value.downcase)
  end

  def permissions
    User::Permissions.new(self)
  end

  def statistics
    @statistics ||= Statistics.new(self)
  end
end
