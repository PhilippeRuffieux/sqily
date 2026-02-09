require "test_helper"

class SessionsControllerTest < ActionController::TestCase
  def test_show
    get(:show)
    assert_response(:success)
  end

  def test_create
    post(:create, params: {email: "ALEXIS@basesecrete.test", password: "password"})
    assert_redirected_to(skills_path(base))
    assert(cookies[:session_token])
  end

  def test_create_with_wrong_password
    post(:create, params: {email: "alexis@basesecrete.test", password: "wrong"})
    assert_response(:success)
  end

  def test_create_with_invitation_token
    cookies.signed[:invitation_token] = invitations(:philippe_hep).token
    post(:create, params: {email: "alexis@basesecrete.test", password: "password"})
    assert_redirected_to(skills_path(hep))
    refute(cookies.signed[:invitation_token])
  end

  def test_destroy
    cookies.permanent.signed[:session_token] = "token"
    delete(:destroy)
    assert_redirected_to("/")
    refute(cookies.signed[:session_token])
  end
end
