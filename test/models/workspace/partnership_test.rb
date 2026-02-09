require "test_helper"

class Workspace::PartnershipTest < ActiveSupport::TestCase
  def test_unread
    partnership = workspace_partnerships(:ror_development_alexis)
    assert(partnership.unread?)
    partnership.update!(read_at: partnership.workspace.updated_at + 1)
    refute(partnership.unread?)
    partnership.update!(read_at: partnership.workspace.updated_at - 1)
    assert(partnership.unread?)
  end
end
