require "test_helper"

class SubscriptionsControllerTest < ActionController::TestCase
  def test_complete
    login(alexis)
    subscription = subscriptions(:js_antoine)
    post(:complete, params: {permalink: "base-secrete", id: subscription.id})
    assert_redirected_to("/base-secrete/skills/#{subscription.skill_id}")
    assert(subscription.reload.completed_at)
  end

  def test_complete_when_current_user_is_not_expert
    login(alexis)
    memberships(:alexis_base).update!(moderator: false)
    subscriptions(:js_alexis).uncomplete
    subscription = subscriptions(:js_antoine)
    post(:complete, params: {permalink: "base-secrete", id: subscription.id})
    assert_redirected_to("/base-secrete/skills/#{subscription.skill_id}")
    refute(subscription.reload.completed_at)
  end

  def test_uncomplete
    login(alexis)
    (subscription = subscriptions(:js_antoine)).touch(:completed_at)
    post(:uncomplete, params: {permalink: "base-secrete", id: subscription.id})
    assert_redirected_to("/base-secrete/skills/#{subscription.skill_id}")
    refute(subscription.reload.completed_at)
  end

  def test_uncomplete_when_current_user_is_not_moderator
    login(alexis)
    memberships(:alexis_base).update!(moderator: false)
    (subscription = subscriptions(:js_antoine)).touch(:completed_at)
    post(:uncomplete, params: {permalink: "base-secrete", id: subscription.id})
    assert_redirected_to("/base-secrete/skills/#{subscription.skill_id}")
    assert(subscription.reload.completed_at)
  end
end
