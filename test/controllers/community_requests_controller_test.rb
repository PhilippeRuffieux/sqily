require "test_helper"

class CommunityRequestsControllerTest < ActionDispatch::IntegrationTest
  def test_new
    get("/community_requests/new")
    assert_response(:success)
  end

  def test_create_when_connected
    login(alexis)
    assert_difference("CommunityRequest.count") do
      post("/community_requests", params: {community_request: community_request_params})
      assert_redirected_to("/")
    end
  end

  def test_create_when_new_user
    assert_difference("User.count") do
      assert_difference("CommunityRequest.count") do
        post("/community_requests", params: {community_request: community_request_params, user: user_params})
        assert_redirected_to("/")
      end
    end
  end

  def test_create_with_error
    post("/community_requests", params: {community_request: community_request_params, user: user_params.merge(name: nil)})
    assert_response(:success)
  end

  private

  def community_request_params
    {name: "Name", description: "Description", comment: "Comment"}
  end

  def user_params
    {name: "Test", email: "test@test.com", password: "password"}
  end
end
