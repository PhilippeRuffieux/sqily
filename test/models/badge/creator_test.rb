require "test_helper"

class Badge::CreatorTest < ActiveSupport::TestCase
  def test_trigger
    Homework.all.each(&:destroy)
    Evaluation.all.destroy_all
    description = "some desc"
    assert_no_difference("Badge::Creator.count") { Evaluation.create!(user: alexis, skill: js, description: description) }
    assert_difference("Badge::Creator.count") { Evaluation.create!(user: alexis, skill: ror, description: description) }
    assert_no_difference("Badge::Creator.count") { Evaluation.create!(user: alexis, skill: skills(:html), description: description) }
  end
end
