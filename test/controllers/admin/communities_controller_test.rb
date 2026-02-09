require "test_helper"

class Admin::CommunitiesControllerTest < ActionController::TestCase
  def test_index
    login_as_admin
    get(:index)
    assert_response(:success)
  end

  def test_index_when_not_admin
    login(users(:alexis))
    get(:index)
    assert_redirected_to("/")
  end

  def test_statistics
    login(admin)
    get(:statistics, params: {order: "users:desc"})
    assert_response(:success)
  end

  def test_statistics_in_csv
    login(admin)
    assert_enqueued_with(job: Community::SendStatisticsJob, args: [admin.email]) do
      get(:statistics, format: :csv)
      assert_redirected_to(admin_communities_path)
    end
  end

  def test_create
    login_as_admin
    assert_difference("Community.count") do
      post(:create, params: {community: {name: "Test", description: "Bla bla bla ..."}})
      assert_redirected_to("/admin/communities")
    end
  end

  def test_create_with_error
    login_as_admin
    post(:create, params: {community: {name: nil}})
    assert_response(:success)
  end

  def test_update
    login(admin)
    community = Community.last
    patch(:update, params: {id: community, community: {name: "New name", description: "New description"}})
    assert_redirected_to(admin_communities_path)
    community.reload
    assert_equal("New name", community.name)
    assert_equal("New description", community.description)
  end

  def test_update_with_errors
    login(admin)
    patch(:update, params: {id: Community.last, community: {name: "", description: ""}})
    assert_response(:success)
  end

  def test_destroy
    login_as_admin
    assert_difference("Community.count", -1) do
      delete(:destroy, params: {id: communities(:base)})
      assert_redirected_to("/admin/communities")
    end
  end

  def test_duplicate
    login(admin)
    attrs = {name: "New", description: "Lorem ipsum", permalink: "new"}
    assert_difference("Community.count") do
      post(:duplicate, params: {id: base, community: attrs})
      assert_redirected_to("/admin/communities/#{Community.last.permalink}")
    end
  end
end
