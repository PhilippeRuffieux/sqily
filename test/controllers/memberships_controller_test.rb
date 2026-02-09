require "test_helper"

class MembershipsControllerTest < ActionController::TestCase
  def setup
    User.any_instance.stubs(:save_avatar)
  end

  def test_show
    login(users(:alexis))
    membership = memberships(:alexis_base)
    get(:show, params: {permalink: membership.community.permalink, id: membership.id})
    assert_response(:success)
  end

  def test_create
    login(users(:alexis))
    assert_difference("Membership.count") do
      post(:create, params: {permalink: communities(:hep).permalink, registration_code: "pa$$w0rd"})
      assert_redirected_to(skills_path(hep))
    end
  end

  def test_create_with_bad_registration_code
    login(users(:alexis))
    assert_no_changes("Membership.count") do
      post(:create, params: {permalink: communities(:hep).permalink, registration_code: "multi-pass"})
      assert_redirected_to("/hep/invitation_requests")
    end
  end

  def test_create_with_deactivated_registration_code
    login(users(:admin))
    assert_no_changes("Membership.count") do
      post(:create, params: {permalink: communities(:base).permalink, registration_code: "multi-pass"})
      assert_redirected_to("/base-secrete/invitation_requests")
    end
  end

  def test_create_when_already_member
    Membership.create!(user: users(:alexis), community: communities(:hep))

    login(users(:alexis))
    assert_no_changes("Membership.count") do
      post(:create, params: {permalink: communities(:hep).permalink, registration_code: "pa$$w0rd"})
      assert_redirected_to("/hep/skills")
    end
  end

  def test_update
    login(user = users(:alexis))
    membership = memberships(:alexis_base)
    avatar = fixture_file_upload("image.jpg", "image/jpeg")
    put(:update, params: {permalink: membership.community.permalink, id: membership.id, membership: {description: "Ma bio"}, user: {name: "Alex", avatar: avatar}})
    assert_redirected_to(skills_path(base))
    assert_equal("Ma bio", membership.reload.description)
    assert_equal("Alex", user.reload.name)
    assert(user.avatar_name)
  end

  def test_update_with_errors
    login(users(:alexis))
    membership = memberships(:alexis_base)
    put(:update, params: {permalink: membership.community.permalink, id: membership.id, membership: {description: "Ma bio"}, user: {name: ""}})
    assert_response(:success)
  end

  def test_moderator
    login(users(:alexis))
    membership = memberships(:antoine_base)
    put(:moderator, params: {permalink: membership.community.permalink, id: membership.id})
    assert_redirected_to("/base-secrete/skills")
    assert(membership.reload.moderator)
  end
end
