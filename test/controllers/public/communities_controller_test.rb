require "test_helper"

class Public::CommunitiesControllerTest < ActionController::TestCase
  def test_index
    get(:index)
    assert_response(:success)
  end
end
