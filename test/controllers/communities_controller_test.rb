require "test_helper"

class CommunitiesControllerTest < ActionController::TestCase
  def test_log_page_view
    login(alexis)
    assert_difference("PageView.count") do
      get(:tree, params: {permalink: communities(:base)})
      assert_response(:success)
    end
  end

  def test_tree
    login(users(:alexis))
    get(:tree, params: {permalink: communities(:base)})
    assert_response(:success)
  end

  def test_tree_when_not_connected
    get(:tree, params: {permalink: communities(:base)})
    assert_response(:success)
  end

  def test_edit
    login(alexis)
    get(:edit, params: {permalink: base})
    assert_response(:success)
  end

  def test_edit_when_not_moderator
    login(antoine)
    get(:edit, params: {permalink: base})
    assert_response(:redirect)
  end

  def test_update
    login(alexis)
    patch(:update, params: {permalink: base, community: {name: "New name"}})
    assert_redirected_to(skills_path(base))
    assert_equal("New name", base.reload.name)
  end

  def test_update_with_error
    login(alexis)
    patch(:update, params: {permalink: base, community: {name: ""}})
    assert_response(:success)
  end

  def test_state
    login(alexis)
    get(:state, params: {permalink: base})
    assert_response(:success)
  end

  def test_duplicate
    login(alexis)
    post(:duplicate, params: {permalink: base, community: {name: "Clone", permalink: "clone"}})
    assert_redirected_to("/clone/skills")
  end

  def test_progression
    login(alexis)
    get(:progression, params: {permalink: base})
    assert_response(:success)
  end

  def test_messages
    login(alexis)
    (membership = memberships(:alexis_base)).update!(last_read_at: nil)
    get(:messages, params: {permalink: base})
    assert_response(:success)
    assert(membership.reload.last_read_at)
  end
end
