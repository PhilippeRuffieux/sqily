require "test_helper"

class PagesControllerTest < ActionController::TestCase
  def test_show
    get(:show, params: {slug: pages(:faq).slug})
    assert_response(:success)
  end

  def test_redirect_not_found_on_unknown_slug
    get(:show, params: {slug: "unknown"})
    assert_response(:not_found)
  end

  def test_redirect_not_found_when_not_valid_slug
    get(:show, params: {slug: "not a valid slug !"})
    assert_response(:not_found)
  end
end
