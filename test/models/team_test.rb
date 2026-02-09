require "test_helper"

class TeamTest < ActiveSupport::TestCase
  def test_update_user_ids
    backend = teams(:backend)
    backend.update_user_ids([alexis.id, antoine.id])
    assert_equal(2, backend.memberships.count)
    backend.update_user_ids([alexis.id])
    assert_equal(1, backend.memberships.count)
  end
end
