require "test_helper"

class PrerequisitesControllerTest < ActionController::TestCase
  def test_create
    login(users(:alexis))
    js, html = skills(:js), skills(:html)
    assert_difference("js.prerequisites.count") do
      post(:create, params: {permalink: "base-secrete", skill_id: js.id, prerequisite: {from_skill_id: html.id}})
      assert_response(:success)
    end
  end

  def test_toggle_mandatory
    login(users(:alexis))
    prerequisite = prerequisites(:js_to_ror)
    patch(:toggle_mandatory, params: {permalink: "base-secrete", skill_id: prerequisite.to_skill_id, id: prerequisite.id})
    assert_response(:success)
    assert(prerequisite.reload.mandatory)
  end

  def test_destroy
    login(users(:alexis))
    prerequisite = prerequisites(:js_to_ror)
    assert_difference("prerequisite.to_skill.prerequisites.count", -1) do
      delete(:destroy, params: {permalink: "base-secrete", skill_id: prerequisite.to_skill_id, id: prerequisite.id})
      assert_response(:success)
    end
  end
end
