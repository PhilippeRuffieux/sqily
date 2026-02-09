require "test_helper"

class Profile::MembershipsControllerTest < ActionDispatch::IntegrationTest
  def test_show
    get("/base-secrete/profile/#{memberships(:alexis_base).id}")
    assert_response(:success)
  end

  def test_public
    login(alexis)
    (membership = memberships(:alexis_base)).update(public: false)
    post("/base-secrete/profile/#{memberships(:alexis_base).id}/public", params: {permalink: "base-secrete", id: membership.id})
    assert_redirected_to("/base-secrete/profile/#{membership.id}")
    assert(membership.reload.public)
  end

  def test_private
    login(alexis)
    (membership = memberships(:alexis_base)).update(public: true)
    post("/base-secrete/profile/#{memberships(:alexis_base).id}/private", params: {permalink: "base-secrete", id: membership.id})
    assert_redirected_to("/base-secrete/profile/#{membership.id}")
    refute(membership.reload.public)
  end
end
