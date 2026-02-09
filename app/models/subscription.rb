class Subscription < ActiveRecord::Base
  belongs_to :skill
  belongs_to :user
  belongs_to :validator, class_name: "User", optional: true
  has_many :homeworks, dependent: :destroy
  has_many :exams, class_name: "Evaluation::Exam"
  has_one :draft, class_name: "Evaluation::Draft"

  validates_presence_of :skill_id, :user_id

  scope :pending, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :pinned, -> { where.not(pinned_at: nil) }
  scope :validated_by, ->(user) { where(validator_id: user.id) }
  scope :in_community, ->(community) { joins(:skill).where(skills: {community: community}) }
  scope :with_unread_messages, -> { where("SELECT MAX(messages.created_at) > subscriptions.last_read_at FROM messages WHERE to_skill_id = subscriptions.skill_id") }

  def toggle_pinned_at
    update(pinned_at: pinned_at ? nil : Time.now)
    pinned_at
  end

  def complete(validator = nil)
    if !completed_at
      Subscription.transaction do
        update!(completed_at: Time.now, validator: validator)
        parent&.refresh_completed_at
      end
    end
  end

  def uncomplete
    if completed_at
      update!(completed_at: nil, validator: nil)
      parent&.uncomplete
      exams.each do |exam|
        if exam.completed?
          exam.notes.update_all(is_accepted: false)
          exam.update!(is_canceled: true)
        end
      end
    end
  end

  def refresh_completed_at
    if skill.children.any?
      mandatory_ids = skill.children.mandatory.published.ids
      completed_ids = children.completed.joins(:skill).merge(Skill.published).pluck(:skill_id)
      (mandatory_ids.all? { |id| completed_ids.include?(id) }) ? complete : uncomplete
    end
  end

  def membership
    user.memberships.where(community_id: skill.community_id).first if user
  end

  def children
    if skill_id
      skill_ids = Skill.where(parent: skill_id).ids
      Subscription.where(user: user_id, skill_id: skill_ids)
    else
      Subscription.none
    end
  end

  def parent
    @parent ||= skill&.parent_id && Subscription.where(user: user_id, skill: skill.parent_id).first
  end

  def unread_messages
    last_read_at ? skill.messages.created_after(last_read_at) : skill.messages
  end

  def attachment_path
    "#{AwsFileStorage.aws_bucket_prefix}/subscriptions/attachments/#{id}/"
  end
end
