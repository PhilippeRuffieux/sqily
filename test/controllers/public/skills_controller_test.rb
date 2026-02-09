require "test_helper"

class Public::SkillsControllerTest < ActionController::TestCase
  def test_index
    get(:index, params: {permalink: communities(:hep).permalink})
    assert_response(:success)
  end

  def test_index_when_community_does_not_exist
    get(:index, params: {permalink: "klingon"})
    assert_response(:not_found)
  end

  def test_index_when_community_is_private
    get(:index, params: {permalink: "base-secrete"})
    assert_redirected_to(invitation_requests_path(base))
  end

  def test_show
    get(:show, params: {permalink: hep, id: skills(:hep_equations)})
    assert_response(:success)
  end

  def test_show_when_skill_is_not_published
    skills(:hep_equations).update!(published_at: nil)
    assert_raise(ActiveRecord::RecordNotFound) do
      get(:show, params: {permalink: hep, id: skills(:hep_equations)})
    end
  end
end
