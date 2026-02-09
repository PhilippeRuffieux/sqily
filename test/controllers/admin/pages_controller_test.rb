require "test_helper"

class Admin::PagesControllerTest < ActionController::TestCase
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

  def test_create
    login_as_admin
    assert_difference("Page.count") do
      post(:create, params: {page: {title: "Test", slug: "test", content: "Bla bla bla ..."}})
      assert_redirected_to(%r{/admin/pages/[0-9]+})
    end
  end

  def test_create_with_error
    login_as_admin
    post(:create, params: {page: {slug: nil}})
    assert_response(:success)
  end

  def test_destroy
    login_as_admin
    assert_difference("Page.count", -1) do
      delete(:destroy, params: {id: pages(:faq)})
      assert_redirected_to("/admin/pages")
    end
  end
end
