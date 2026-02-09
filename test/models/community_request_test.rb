require "test_helper"

class CommunityRequestTest < ActiveSupport::TestCase
  def test_accept
    assert_emails(1) do
      assert_difference("CommunityRequest.pending.count", -1) do
        assert_difference("Membership.moderator.count") do
          assert_difference("Community.count") do
            community_requests(:genevarb).accept
          end
        end
      end
    end
  end

  def test_accept_with_same_permalink
    (req = community_requests(:genevarb)).update(name: "hep")
    assert_match(/hep\d/, req.accept.permalink)
  end
end
