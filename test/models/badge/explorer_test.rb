require "test_helper"

class Badge::ExplorerTest < ActiveSupport::TestCase
  def setup
    Message::Upload.any_instance.stubs(:save_file)
  end

  def test_trigger_with_community_message
    Badge::Explorer.stubs(required_count: 3)
    assert_no_difference("Badge::Explorer.count") { Message::Upload.create!(from_user: alexis, to_community: base, file: file) }
    assert_difference("Badge::Explorer.count") { Message::Upload.create!(from_user: alexis, to_community: base, file: file) }
    assert_no_difference("Badge::Explorer.count") { Message::Upload.create!(from_user: alexis, to_community: base, file: file) }
  end

  def test_trigger_with_skill_message
    Badge::Explorer.stubs(required_count: 3)
    assert_no_difference("Badge::Explorer.count") { Message::Upload.create!(from_user: alexis, to_skill: ror, file: file) }
    assert_difference("Badge::Explorer.count") { Message::Upload.create!(from_user: alexis, to_skill: ror, file: file) }
    assert_no_difference("Badge::Explorer.count") { Message::Upload.create!(from_user: alexis, to_skill: ror, file: file) }
  end

  def test_trigger_with_workspace_message
    Badge::Explorer.stubs(required_count: 2)
    assert_no_difference("Badge::Explorer.count") { Message::Upload.create!(from_user: alexis, to_workspace: workspaces(:ror_development), file: file) }
  end

  def test_trigger_with_private_message
    Badge::Explorer.stubs(required_count: 2)
    assert_no_difference("Badge::Explorer.count") { Message::Upload.create!(from_user: alexis, to_user: antoine, file: file) }
  end

  private

  def file
    Rails.root.join("test/fixtures/files/image.jpg")
  end
end
