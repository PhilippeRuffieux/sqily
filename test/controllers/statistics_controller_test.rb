require "test_helper"

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  def test_index
    login(alexis)
    get(statistics_path(base))
    assert_response(:success)
  end

  def test_index_when_not_moderator
    login(antoine)
    get(statistics_path(base))
    assert_redirected_to(skills_path(base))
  end
end
