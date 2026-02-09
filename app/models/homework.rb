class Homework < ActiveRecord::Base
  belongs_to :evaluation
  belongs_to :subscription

  include AwsFileStorage

  validates_presence_of :subscription_id, :subscription_id

  scope :pending, -> { where(approved_at: nil, rejected_at: nil).where.not(file_node: nil) }
  scope :pending_or_not_submitted, -> { where("(approved_at IS NULL AND rejected_at IS NULL) OR file_node IS NULL") }
  scope :approved, -> { where.not(approved_at: nil) }
  scope :to_approver, ->(user) { joins(:evaluation).where(evaluations: {user_id: user}) }
  scope :from_author, ->(user) { joins(:subscription).where(subscriptions: {user_id: user}) }
  scope :from_community, ->(community) { joins(:evaluation).where(evaluations: {skill_id: community.skills.pluck(:id)}) }

  def self.for_skill(skill)
    where("(SELECT evaluations.skill_id FROM evaluations WHERE evaluations.id = homeworks.evaluation_id) = ?", skill.id)
  end

  def approve(by_user)
    update(approved_at: Time.now, rejected_at: nil)
    subscription.complete(by_user)
  end

  def reject
    update(approved_at: nil, rejected_at: Time.now)
    UserMailer.homework_rejected(self).deliver_now
  end

  def reject_and_keep_open
    reject
    Homework.create!(evaluation: evaluation, subscription: subscription)
  end

  def pending?
    !approved_at && !rejected_at
  end
end
