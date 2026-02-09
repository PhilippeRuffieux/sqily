require "test_helper"

class PasswordResetsControllerTest < ActionController::TestCase
  def test_index
    get(:index)
    assert_response(:success)
  end

  def test_index_when_connected
    login(users(:alexis))
    get(:index)
    assert_redirected_to("/")
  end

  def test_create
    assert_difference("PasswordReset.count") do
      post(:create, params: {email: "alexis@basesecrete.test"})
      assert_redirected_to("/")
    end
  end

  def test_create_when_email_does_not_exist
    post(:create, params: {email: "does@bnot.exist"})
    assert_response(:success)
  end

  def test_show
    get(:show, params: {id: password_resets(:alexis).token})
    assert_redirected_to("/base-secrete/memberships/#{memberships(:alexis_base).id}")
    assert_equal(users(:alexis), @controller.send(:current_user))
  end

  def test_show_when_expired
    (reset = password_resets(:alexis)).touch(:expired_at)
    get(:show, params: {id: reset.token})
    assert_redirected_to("/password_resets")
  end
end
