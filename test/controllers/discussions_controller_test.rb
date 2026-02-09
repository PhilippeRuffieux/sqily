require "test_helper"

class DiscussionsControllerTest < ActionController::TestCase
  def test_index
    login(users(:alexis))
    get(:index, params: {permalink: "base-secrete"})
    assert_response(:success)
  end
end
