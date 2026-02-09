require "test_helper"

class MessagesHelperTest < ActiveSupport::TestCase
  include MessagesHelper

  def test_is_message_attachment_an_image?
    refute(is_message_attachment_an_image?(Message::Upload.new(file_node: "node/book.pdf")))
    assert(is_message_attachment_an_image?(Message::Upload.new(file_node: "node/image.jPG")))
    assert(is_message_attachment_an_image?(Message::Upload.new(file_node: "node/image.PNG")))
  end

  def test_is_message_attachment_audio?
    refute(is_message_attachment_audio?(Message::Upload.new(file_node: "node/book.pdf")))
    assert(is_message_attachment_audio?(Message::Upload.new(file_node: "node/file.oGG")))
    assert(is_message_attachment_audio?(Message::Upload.new(file_node: "node/file.Mp3")))
  end

  def test_highlight_current_user
    stubs(current_user: stub(name: "test"))
    assert_equal("Hello <mark>TEST</mark>!", highlight_current_user("Hello TEST!"))
    assert_equal("testtest", highlight_current_user("testtest"))
    stubs(current_user: stub(name: "Milo;)"))
    assert_equal("Hello <mark>Milo;)</mark>!<mark>milo;)</mark> testMilo;) Milo;)test", highlight_current_user("Hello Milo;)!milo;) testMilo;) Milo;)test"))
  end
end
