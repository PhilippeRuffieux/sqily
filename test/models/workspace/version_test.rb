require "test_helper"

class Workspace::VersionTest < ActiveSupport::TestCase
  def test_previous
    version1 = workspace_versions(:ror_development_1)
    (version2 = workspaces(:ror_development).new_version(title: "Title", writing: "Writing")).save!
    (version3 = workspaces(:ror_development).new_version(title: "Title", writing: "Writing")).save!
    assert_equal(version1, version2.previous)
    assert_equal(version2, version3.previous)
  end
end
