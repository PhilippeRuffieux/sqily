require "test_helper"

class Community::DuplicationJobTest < ActiveJob::TestCase
  def test_perform
    community = nil
    params = {name: "New", description: "Lorem ipsum", permalink: "new"}
    assert_no_emails do
      assert_difference("Prerequisite.count", 2) do
        assert_difference("Community.count") do
          community = Community::DuplicationJob.perform_now(base.id, alexis.id, params)
        end
      end
    end
    assert_equal("New", community.name)
    assert_equal("Lorem ipsum", community.description)
    assert_equal(base.skills.count, community.skills.count)
    assert_equal([alexis], community.users)
    assert_equal(1, community.skills.first.subscriptions.count)
    subscription = community.skills.first.subscriptions.first
    assert_equal(alexis, subscription.user)
    assert(subscription.completed_at)
    assert_equal(2, community.skills.find_by_name("Ruby on Rails").tasks.count)

    programming = community.skills.find_by_name("Programming")
    assert_equal(["JavaScript", "Ruby on Rails"], programming.children.order(:name).pluck(:name))
    assert(programming.subscriptions.first.completed_at)

    assert_equal(0, community.skills.find_by_name("JavaScript").evaluations.count)
  end

  def test_perform_with_evaluations
    community = nil
    params = {name: "New", description: "Lorem ipsum", permalink: "new", duplicate_evaluations: true}
    assert_difference("Community.count") do
      community = Community::DuplicationJob.perform_now(base.id, alexis.id, params)
    end
    assert_equal(2, community.skills.find_by_name("JavaScript").evaluations.count)
  end
end
