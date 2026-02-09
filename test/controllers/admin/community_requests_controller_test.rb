require "test_helper"

class Admin::CommunityRequestsControllerTest < ActionDispatch::IntegrationTest
  def test_index
    login(admin)
    get("/admin/community_requests")
    assert_response(:success)
  end

  def test_destroy
    login(admin)
    assert_difference("CommunityRequest.count", -1) do
      delete("/admin/community_requests/#{community_requests(:genevarb).id}")
      assert_redirected_to("/admin/community_requests")
    end
  end

  def test_accept
    login(admin)
    assert_difference("Community.count") do
      post("/admin/community_requests/#{community_requests(:genevarb).id}/accept")
      assert_redirected_to("/admin/community_requests")
    end
  end
end
