require "test_helper"

class VotesControllerTest < ActionController::TestCase
  def test_index
    login(alexis)
    get(:index, params: {permalink: "base-secrete"})
    assert_response(:success)
  end
end
