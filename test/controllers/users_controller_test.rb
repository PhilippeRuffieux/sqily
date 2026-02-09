require "test_helper"

class UsersControllerTest < ActionController::TestCase
  def test_new_without_invitation
    get(:new)
    assert_redirected_to("/")
  end

  def test_new
    cookies.signed[:invitation_token] = invitations(:philippe_hep).token
    get(:new)
    assert_response(:success)
  end

  def test_new_when_already_connected
    login(users(:alexis))
    get(:new)
    assert_redirected_to(skills_path(base))
  end

  def test_create_with_registration_code_with_community_without_registration_code
    assert_no_changes("Membership.count") do
      assert_no_changes("User.count") do
        post(:create, params: {
          registration_code: "pa$$w0rd",
          community_id: communities(:base).id,
          user: {name: "Philippe", email: "philippe@hep.ch", password: "password"}
        })
        assert_response(:success)
      end
    end
  end

  def test_create_with_registration_code_with_unknown_community
    assert_no_changes("Membership.count") do
      assert_no_changes("User.count") do
        post(:create, params: {
          registration_code: "pa$$w0rd",
          community_id: 42,
          user: {name: "Philippe", email: "philippe@hep.ch", password: "password"}
        })
        assert_response(:success)
      end
    end
  end

  def test_create_with_registration_code_with_community_with_bad_registration_code
    assert_no_changes("Membership.count") do
      assert_no_changes("User.count") do
        post(:create, params: {
          registration_code: "multi-pass",
          community_id: communities(:hep).id,
          user: {name: "Philippe", email: "philippe@hep.ch", password: "password"}
        })
        assert_response(:success)
      end
    end
  end

  def test_create_with_registration_code
    assert_difference("Membership.count") do
      assert_difference("User.count") do
        post(:create, params: {
          registration_code: "pa$$w0rd",
          community_id: communities(:hep).id,
          user: {name: "Philippe", email: "philippe@hep.ch", password: "password"}
        })
        assert_redirected_to(skills_path(hep))
      end
    end
    assert(@controller.send(:current_user))
    refute(cookies.signed[:invitation_token])
  end

  def test_create_with_invitation
    cookies.signed[:invitation_token] = invitations(:philippe_hep).token
    assert_difference("Membership.count") do
      assert_difference("User.count") do
        post(:create, params: {user: {name: "Philippe", email: "philippe@hep.ch", password: "password"}})
        assert_redirected_to(skills_path(hep))
      end
    end
    assert(@controller.send(:current_user))
    refute(cookies.signed[:invitation_token])
  end

  def test_create_with_errors
    cookies.signed[:invitation_token] = invitations(:philippe_hep).token
    post(:create, params: {user: {name: nil, email: "test@email.com", password: "password"}})
    assert_response(:success)
  end

  def test_index
    login(alexis)
    get(:index, params: {permalink: base.permalink})
    assert_response(:success)
  end

  def test_show
    login(users(:alexis))
    community, user = communities(:base), users(:antoine)
    get(:show, params: {permalink: community.permalink, id: user.id})
    assert_response(:success)
  end

  def test_destroy
    login(users(:alexis))
    assert_difference("Membership.count", -1) do
      delete(:destroy, params: {permalink: "base-secrete", id: users(:antoine).id})
      assert_redirected_to(skills_path(base))
    end
  end

  def test_destroy_avatar
    login(user = users(:alexis))
    user.update!(avatar: fixture_file_upload("image.jpg", "image/jpeg"))
    delete(:destroy_avatar, params: {permalink: "base-secrete", id: user.id})
    assert_response(:success)
    refute(user.reload.avatar_path)
  end

  def test_sidebar
    login(alexis)
    get(:sidebar, params: {permalink: base})
    assert_response(:success)
  end
end
