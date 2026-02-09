require "test_helper"

class Events::ParticipationsControllerTest < ActionDispatch::IntegrationTest
  def test_toggle
    login(alexis)
    participation = participations(:js_demo_alexis)
    participation.event.update!(scheduled_at: Time.now, registration_finished_at: Time.now - 1)
    post(toggle_event_participation_path(base, js_demo, participation))
    assert_response(:success)
    assert_equal(true, participation.reload.confirmed)
  end
end
