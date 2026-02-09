require "test_helper"

class Badge::ProfessorTest < ActiveSupport::TestCase
  def test_trigger
    Badge::Professor.stubs(required_count: 2)
    assert_no_difference("Badge::Professor.count") { homeworks(:js_antoine).approve(alexis) }

    homework2 = Homework.create(subscription: subscriptions(:js_antoine), evaluation: evaluations(:html))
    assert_difference("Badge::Professor.count") { homework2.approve(alexis) }

    assert_no_difference("Badge::Professor.count") { Badge::Professor.trigger(homeworks(:js_antoine)) }
  end
end
