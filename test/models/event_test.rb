require "test_helper"

class EventTest < ActiveSupport::TestCase
  def test_validates_scheduled_at_is_after_registration_finished_at
    day1, day2 = 1.day.from_now, 2.days.from_now

    (event = Event.new(scheduled_at: day1, registration_finished_at: day2)).valid?
    assert(event.errors[:registration_finished_at].any?)

    (event = Event.new(scheduled_at: day1, registration_finished_at: day1)).valid?
    refute(event.errors[:registration_finished_at].any?)
  end

  def test_register
    participation = nil
    assert_difference("js_demo.participations.count") { participation = js_demo.register(users(:antoine)) }
    assert_no_difference("js_demo.participations.count") { assert_equal(participation, js_demo.register(users(:antoine))) }
  end

  def test_register_when_full
    js_demo.update!(max_participations: 1)
    assert_difference("js_demo.waiting_participations.count") do
      assert_no_difference("js_demo.participations.count") { js_demo.register(users(:antoine)) }
    end
  end

  def test_unregister
    assert_difference("js_demo.participations.count", -1) { js_demo.unregister(alexis) }
  end

  def test_unregister_from_waiting_list
    js_demo.update!(max_participations: 1)
    js_demo.register(users(:antoine))
    assert_difference("js_demo.waiting_participations.count", -1) { js_demo.unregister(antoine) }
  end

  def test_increase_max_participations_when_there_is_a_waiting_list
    js_demo.update!(max_participations: 1)
    js_demo.register(users(:antoine))
    assert_difference("js_demo.waiting_participations.count", -1) { js_demo.update!(max_participations: 5) }
  end

  def test_registered?
    assert(js_demo.registered?(alexis))
    refute(js_demo.registered?(antoine))
  end

  def test_registerable_when_registrations_are_finished
    assert(js_demo.registerable?(antoine))
    js_demo.update!(registration_finished_at: 1.second.ago)
    refute(js_demo.registerable?(antoine))
  end

  def test_registerable_for_a_skill_event
    assert(js_demo.registerable?(antoine))
    antoine.subscriptions.destroy_all
    refute(js_demo.registerable?(antoine))
  end

  def test_registerable_for_a_community_event
    js_demo.update!(skill: nil, community: base)
    refute(js_demo.registerable?(admin))
    base.add_user(admin)
    assert(js_demo.registerable?(admin))
  end

  def test_editable_by?
    assert(js_demo.editable_by?(alexis))
    refute(js_demo.editable_by?(antoine))
  end
end
