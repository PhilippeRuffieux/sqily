class PollChoice < ActiveRecord::Base
  belongs_to :poll
  has_many :answers, class_name: "PollAnswer", foreign_key: "choice_id"

  validates_presence_of :title

  def answer(user)
    if poll.answerable_by?(user)
      answers.create!(user: user)
    end
  end
end
