class Skill < ActiveRecord::Base
  belongs_to :community
  belongs_to :creator, class_name: "User", optional: true
  belongs_to :parent, class_name: "Skill", optional: true
  has_many :children, class_name: "Skill", foreign_key: "parent_id"
  has_many :evaluations, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :experts, -> { where("completed_at IS NOT NULL") }, through: :subscriptions, source: :user
  has_many :messages, foreign_key: "to_skill_id", dependent: :delete_all
  has_many :prerequisites, foreign_key: "to_skill_id", dependent: :delete_all
  has_many :next_prerequisites, foreign_key: "from_skill_id", dependent: :delete_all, class_name: "Prerequisite"
  has_many :nex_skills, class_name: "Skill", through: :next_prerequisites
  has_many :tasks
  has_many :exams

  validates_presence_of :name, :description, :community_id
  validates_uniqueness_of :name, scope: :community_id, if: :name, case_sensitive: false
  validate :cannot_not_be_parent_of_itself

  scope :order_by_name, -> { order(:name) }
  scope :order_by_experts, -> {
    order(Arel.sql("(SELECT COUNT(*) FROM subscriptions WHERE subscriptions.skill_id = skills.id AND subscriptions.completed_at IS NOT NULL) DESC"))
  }
  scope :viewable_by, ->(user) { user ? where("published_at IS NOT NULL OR creator_id = ?", user.id) : where("published_at IS NOT NULL") }
  scope :published, -> { where.not(published_at: nil) }
  scope :in_community, ->(community) { where(community: community) }
  scope :roots, -> { where(parent_id: nil) }
  scope :mandatory, -> { where(mandatory: true) }

  around_save :refresh_subscription_validations_around_save

  def refresh_subscription_validations_around_save(&block)
    old_parent = Skill.find(parent_id_was) if parent_id_was
    if parent_id_changed? || mandatory_changed?
      skill_ids = [parent_id, parent_id_was].uniq
    elsif mandatory_changed?
      skill_ids = [parent_id]
    end

    if block.call && skill_ids.present?
      parent&.reorganize_subscriptions
      old_parent&.reorganize_subscriptions
      Subscription.where(skill: skill_ids).each(&:refresh_completed_at)
    end
  end

  def reorganize_subscriptions
    parent_user_ids = subscriptions.pluck(:user_id)
    child_user_ids = Subscription.where(skill_id: child_ids).distinct.pluck(:user_id)
    Subscription.where(user_id: parent_user_ids - child_user_ids, skill_id: id).each(&:destroy)
    User.find(child_user_ids - parent_user_ids).each { |user| subscribe(user) }
  end

  def startable_by?(user)
    skill_ids = prerequisites.pluck(:from_skill_id)
    completed_subscriptions = user.subscriptions.completed
    mandatory_skill_ids = prerequisites.mandatory.pluck(:from_skill_id)
    return false if completed_subscriptions.where(skill_id: skill_ids).count < minimum_prerequisites
    return false if completed_subscriptions.where(skill_id: mandatory_skill_ids).count < mandatory_skill_ids.size
    parent ? parent.startable_by?(user) : true
  end

  def attachment_path
    "#{AwsFileStorage.aws_bucket_prefix}/skills/attachments/#{id}/"
  end

  def subscribe(user)
    subscription = Subscription.find_or_create_by(user: user, skill: self)
    parent&.subscribe(user)
    subscription
  end

  def unsubscribe(user)
    if (subscription = subscriptions.where(user: user).first)
      subscription.homeworks.each(&:destroy)
      subscription.exams.each(&:destroy)
      subscription.draft.try(:destroy)
      subscription.destroy
      if subscription.parent
        subscription.parent.uncomplete
        parent.unsubscribe(user) if subscription.parent.children.none?
      end
    end
  end

  def can_have_children?
    !parent && evaluations.empty?
  end

  def remove_foreign_prerequisites
    skill_ids = parent ? parent.children.ids : community.skills.roots.ids
    next_prerequisites.where.not(to_skill_id: skill_ids).each(&:destroy)
    prerequisites.where.not(from_skill_id: skill_ids).each(&:destroy)
  end

  def destroyable?
    persisted? && children.none?
  end

  def cannot_not_be_parent_of_itself
    if persisted? && parent_id == id
      errors.add(:parent_id, :invalid)
    end
  end
end
