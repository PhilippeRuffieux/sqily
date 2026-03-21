require "test_helper"

class ApplicationHelperTest < ActiveSupport::TestCase
  include ApplicationHelper
  include AutoEmbedHelper
  include HashTagsHelper
  include MessagesHelper
  include ERB::Util

  setup do
    stubs(current_user: nil)
    stubs(request: stub(host: "www.sqily.com"))
  end

  def test_format_rich_text_keeps_plain_urls_opening_in_a_new_tab
    assert_equal('<a href="http://www.sqily.com" target="_blank">http://www.sqily.com</a>', format_rich_text("http://www.sqily.com"))
  end

  def test_format_rich_text_forces_editor_links_to_open_in_a_new_tab
    result = format_rich_text('<a href="https://example.com">Example</a>'.html_safe)

    assert_includes(result, 'href="https://example.com"')
    assert_includes(result, 'target="_blank"')
  end

  def test_format_rich_text_overrides_existing_link_target
    result = format_rich_text('<a href="https://example.com" target="_self">Example</a>'.html_safe)

    assert_includes(result, 'href="https://example.com"')
    assert_includes(result, 'target="_blank"')
    refute_includes(result, 'target="_self"')
  end
end
