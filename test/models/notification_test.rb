require "test_helper"

class EventTest < ActiveSupport::TestCase
  def test_replay
    old_count = Notification.count
    Notification.replay
    assert(Notification.count > old_count)
  end
end
