require "test_helper"

class InvitationsControllerTest < ActionController::TestCase
  def test_index
    login(users(:alexis))
    get(:index, params: {permalink: communities(:base).permalink})
    assert_response(:success)
  end

  def test_create
    login(users(:alexis))
    assert_difference("Invitation.count", 2) do
      post(:create, params: {permalink: communities(:base).permalink, invitation: {email: "test1@email.com\ntest2@email.com"}})
      assert_redirected_to("/base-secrete/invitations")
    end
  end

  def test_create_with_error
    login(users(:alexis))
    assert_difference("Invitation.count", 1) do
      post(:create, params: {permalink: communities(:base).permalink, invitation: {email: "test1@email.com\ninvalid email"}})
      assert_response(:success)
    end
  end

  def test_show_when_user_is_connected
    login(user = users(:alexis))
    invitation = invitations(:philippe_hep)
    get(:show, params: {permalink: invitation.community, token: invitation.token})
    assert_redirected_to(skills_path(hep))
    assert(user.communities.include?(invitation.community))
  end

  def test_show_when_vistor_is_anonymous
    invitation = invitations(:philippe_hep)
    get(:show, params: {permalink: invitation.community, token: invitation.token})
    assert_redirected_to("/users/new")
    assert_equal(invitation.token, cookies.signed[:invitation_token])
  end

  def test_destroy
    login(users(:admin))
    invitation = invitations(:philippe_hep)
    delete(:destroy, params: {permalink: invitation.community, token: invitation.token})
    assert_redirected_to("/hep/invitations")
  end
end
