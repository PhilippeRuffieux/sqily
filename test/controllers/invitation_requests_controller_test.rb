require "test_helper"

class InvitationRequestsControllerTest < ActionController::TestCase
  def test_index
    get(:index, params: {permalink: communities(:hep).permalink})
    assert_response(:success)
  end

  def test_index_when_member
    login(alexis)
    get(:index, params: {permalink: base.permalink})
    assert_redirected_to(skills_path(base))
  end

  def test_create
    assert_difference("InvitationRequest.count") do
      post(:create, params: {permalink: communities(:hep).permalink, invitation_request: {email: "test@email.com"}})
      assert_response(:success)
    end
  end

  def test_create_when_email_is_already_used
    post(:create, params: {permalink: communities(:hep).permalink, invitation_request: {email: "student@email.com"}})
    assert_response(:success)
  end

  def test_update
    login(users(:admin))
    invitation_request = invitation_requests(:student_hep)
    put(:update, params: {permalink: invitation_request.community.permalink, id: invitation_request.id})
    assert_redirected_to("/hep/invitations")
  end
end
