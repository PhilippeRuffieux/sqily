require "test_helper"

class EventsControllerTest < ActionController::TestCase
  def setup
    login(alexis)
    Event.any_instance.stubs(:save_file)
  end

  def test_index
    get(:index, params: {permalink: base})
    assert_response(:success)
  end

  def test_new
    get(:new, params: {permalink: base})
    assert_response(:success)
  end

  def test_new_for_skill
    get(:new, params: {permalink: base, skill_id: ror.id})
    assert_response(:success)
  end

  def test_create
    assert_difference("Event.count") do
      post(:create, params: {permalink: base, event: event_params})
    end
    assert_redirected_to(skills_path(base))
  end

  def test_create_for_skill
    assert_difference("Event.count") do
      post(:create, params: {permalink: base, event: event_params.merge(skill_id: ror.id)})
    end
    assert_redirected_to(skill_path(base, ror))
    assert_equal(ror, Event.last.skill)
  end

  def test_create_with_errors
    assert_no_difference("Event.count") do
      post(:create, params: {permalink: base, event: event_params.merge(title: nil)})
    end
    assert_response(:success)
  end

  def test_show
    get(:show, params: {permalink: base, id: js_demo})
    assert_response(:success)
  end

  def test_show_when_not_creator
    login(antoine)
    get(:show, params: {permalink: base, id: js_demo})
    assert_response(:not_found)
  end

  def test_update
    patch(:update, params: {permalink: base, id: js_demo, event: {title: "New title"}})
    assert_redirected_to(skill_path(base, js))
    assert_equal("New title", js_demo.reload.title)
  end

  def test_update_with_errors
    patch(:update, params: {permalink: base, id: js_demo, event: {title: ""}})
    assert_response(:success)
  end

  def test_update_when_not_allowed
    login(antoine)
    patch(:update, params: {permalink: base, id: js_demo, event: {title: "New title"}})
    assert_response(:not_found)
  end

  def test_destroy
    assert_difference("Event.count", -1) do
      delete(:destroy, params: {permalink: base, id: js_demo.id})
      assert_redirected_to(skill_path(base, js))
    end
  end

  def test_register
    login(antoine)
    assert_difference("Participation.count") do
      post(:register, params: {permalink: base, id: js_demo})
      assert_redirected_to(skill_path(base, js))
    end
    assert_equal(js_demo, Participation.last.event)
    assert_equal(antoine, Participation.last.user)
  end

  def test_unregister
    login(alexis)
    assert_difference("Participation.count", -1) do
      delete(:unregister, params: {permalink: base, id: js_demo})
      assert_redirected_to(skill_path(base, js))
    end
  end

  private

  def event_params
    {
      title: "Test",
      scheduled_at: 2.days.from_now,
      registration_finished_at: 1.day.from_now,
      max_participations: 5,
      file: fixture_file_upload("image.jpg", "image/jpeg")
    }
  end
end
