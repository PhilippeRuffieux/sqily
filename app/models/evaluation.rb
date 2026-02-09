class Evaluation < ActiveRecord::Base
  belongs_to :skill
  belongs_to :user
  has_many :exams, class_name: "Evaluation::Exam"

  validates_presence_of :skill_id, :user_id, :description

  scope :one_version_per_user, -> { where("evaluations.id = (SELECT MAX(id) FROM evaluations as e WHERE e.user_id = evaluations.user_id AND e.skill_id = evaluations.skill_id)") }
  scope :in_community, ->(community) { where("(SELECT community_id FROM skills WHERE skills.id = evaluations.skill_id) = ?", community.id) }
  scope :from_user, ->(user_id) { where(user_id: user_id) }
  scope :not_disabled, -> { where(disabled_at: nil) }
  scope :listable_by, ->(user) { where("disabled_at IS NULL OR user_id = ?", user) }

  include AwsFileStorage

  def attachment_path
    "#{AwsFileStorage.aws_bucket_prefix}/evaluations/attachments/#{id}/"
  end

  def start(subscription, content)
    return if subscription.exams.ongoing.any?
    ActiveRecord::Base.transaction do
      examiner = pick_examiner_for(subscription)
      if (exam = Evaluation::Exam.where(evaluation: self, subscription: subscription, examiner: examiner).first)
        exam.resume
      else
        exam = Evaluation::Exam.new(evaluation: self, subscription: subscription, examiner: examiner)
        exam.save && Evaluation::Note.create!(content: content, user: subscription.user, exam: exam)
      end
      exam
    end
  end

  def membership
    skill.community.memberships.find_by_user_id(user_id)
  end

  def disabled?
    disabled_at != nil
  end

  def destroyable?
    exams.none?
  end

  def pick_examiner_for(subscription)
    previous_examiner_ids = exams.where(subscription_id: subscription).pluck(:examiner_id)
    sql = "(SELECT COUNT(*) FROM evaluation_exams WHERE examiner_id = users.id AND evaluation_id IN (?))"
    less_busy_experts = skill.experts.order(Arel.sql(Evaluation.sanitize_sql([sql, skill.evaluation_ids])))
    less_busy_experts_in_same_team = less_busy_experts.joins(:memberships).where(memberships: {team_id: subscription.membership.team_id})
    less_busy_experts_in_same_team.where.not(id: previous_examiner_ids).first ||
      less_busy_experts.where.not(id: previous_examiner_ids).first ||
      less_busy_experts.limit(10).sample
  end
end
