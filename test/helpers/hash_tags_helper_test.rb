require "test_helper"

class MessagesHelperTest < ActiveSupport::TestCase
  include ActionView::Helpers::UrlHelper
  include HashTagsHelper

  def test_hash_tags_to_links
    assert_equal('Voici un <a href="/foo/bar">#tag</a>', hash_tags_to_links("Voici un #tag"))
    assert_equal('<a href="/foo/bar">#tag</a>', hash_tags_to_links("#tag"))
  end

  private

  def params
    ActionController::Parameters.new(controller: "foo", action: "bar")
  end

  def url_for(params)
    "/foo/bar"
  end
end
