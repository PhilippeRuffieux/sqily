class Event < ActiveRecord::Base
  include AwsFileStorage

  TypeScopes.inject self

  belongs_to :community, required: false
  belongs_to :skill, required: false
  belongs_to :user
  has_one :message
  has_many :participations
  has_many :waiting_participations
  has_many :users, through: :participations

  validates_presence_of :title, :scheduled_at, :registration_finished_at
  validates_numericality_of :max_participations, greater_than: 0
  validate :validates_either_community_or_skill_is_present

  validate :validates_scheduled_at_is_after_registration_finished_at

  after_update :register_next_waiting_participations

  def register(user)
    if registerable?(user)
      if full?
        waiting_participations.create!(user: user)
      else
        participations.where(user_id: user).first || participations.create!(user: user)
      end
    end
  end

  def unregister(user)
    participations.where(user: user).first.try(:destroy)
    waiting_participations.where(user: user).first.try(:destroy)
    register_next_waiting_participations
  end

  def registered?(user)
    users.where(id: user.id).exists?
  end

  def register_next_waiting_participations
    while !full? && (wp = waiting_participations.order(:created_at).first)
      wp.register
    end
  end

  def registerable?(user)
    if registration_finished_at < Time.now
      false
    elsif skill_id
      user.subscriptions.where(skill_id: skill_id).exists?
    elsif community_id
      user.memberships.where(community_id: community_id).exists?
    end
  end

  def full?
    participations.count >= max_participations
  end

  def editable_by?(user)
    user_id == user.id
  end

  def validates_scheduled_at_is_after_registration_finished_at
    if scheduled_at && registration_finished_at && scheduled_at < registration_finished_at
      errors.add(:registration_finished_at, :must_be_before_scheduled_at)
    end
  end

  def validates_either_community_or_skill_is_present
    errors.add(:community, :blank) if !community && !skill
  end
end
