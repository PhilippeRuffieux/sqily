class Poll < ActiveRecord::Base
  TypeScopes.inject self

  belongs_to :user
  belongs_to :skill, optional: true
  belongs_to :community, optional: true
  belongs_to :workspace, optional: true

  has_many :choices, class_name: "PollChoice"
  has_many :answers, class_name: "PollAnswer", through: :choices

  validates_presence_of :title, :finished_at
  validate :validates_finished_at_is_in_the_futur, on: :create
  validate :validates_presence_of_community_or_skill

  def answered_by?(user)
    answers.pluck(:user_id).include?(user.id)
  end

  def editable_by?(user)
    user_id == user.id
  end

  def answerable_by?(user)
    if (single_answer && answered_by?(user)) || finished?
      false
    elsif workspace_id
      workspace.published_at? || user.workspaces.where(id: workspace_id).exists?
    elsif skill_id
      user.subscriptions.where(skill_id: skill_id).exists?
    elsif community_id
      user.memberships.where(community_id: community_id).exists?
    end
  end

  def validates_finished_at_is_in_the_futur
    if finished_at && finished_at <= Date.today
      errors.add(:finished_at, :must_be_in_the_futur)
    end
  end

  def validates_presence_of_community_or_skill
    errors.add(:community_id, :not_blank) if !community_id && !skill_id && !workspace_id
  end

  def finished?
    finished_at <= Time.now
  end
end
