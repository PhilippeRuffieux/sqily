require "test_helper"

class CommunityRequestFormTest < ActiveSupport::TestCase
  def test_create
    assert_emails(1) do
      assert_difference("CommunityRequest.count") do
        CommunityRequestForm.create(community_request: {name: "Name", description: "Description"}, user: alexis)
      end
    end
  end

  def test_create_with_errors
    assert_no_emails do
      assert_no_difference("CommunityRequest.count") do
        CommunityRequestForm.create(community_request: {name: "", description: "Description"}, user: alexis)
      end
    end
  end
end
