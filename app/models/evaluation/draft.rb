class Evaluation::Draft < ApplicationRecord
  belongs_to :subscription
  belongs_to :evaluation

  def submittable?
    evaluation.skill.experts.any?
  end
end
