class Prerequisite < ActiveRecord::Base
  belongs_to :to_skill, class_name: "Skill"
  belongs_to :from_skill, class_name: "Skill"

  validates_presence_of :from_skill, :to_skill
  validate :validates_from_and_to_skill_are_different

  scope :mandatory, -> { where(mandatory: true) }
  scope :published, -> { joins(:from_skill).merge(Skill.published) }

  private

  def validates_from_and_to_skill_are_different
    errors.add(:from_skill, :invaid) if from_skill_id && from_skill_id == to_skill_id
  end
end
