require "test_helper"

class WeeklySummaryJobTest < ActiveSupport::TestCase
  def test_perform_for_all_membeships
    User.update_all(weekly_summary: false)
    alexis.update!(weekly_summary: true)
    assert_emails(1) { WeeklySummaryJob.perform_for_all_membeships }
  end

  def test_perform
    assert_emails(1) { WeeklySummaryJob.perform_now(memberships(:alexis_base)) }
  end

  def test_new_community_messages
    summary = WeeklySummaryJob.new
    assert_emails(1) { summary.perform(memberships(:alexis_base)) }
    assert_equal([messages(:alexis_to_base)], summary.new_community_messages.to_a)
  end

  def test_new_skills
    skills(:html).update!(created_at: 8.days.ago)
    summary = WeeklySummaryJob.new
    assert_emails(1) { summary.perform(memberships(:alexis_base)) }
    assert_equal(["CSS", "Design", "JavaScript", "Ruby on Rails"], summary.new_skills.order(:name).pluck(:name))
  end

  def test_new_memberships
    summary = WeeklySummaryJob.new
    assert_emails(1) { summary.perform(memberships(:alexis_base)) }
    assert_equal([memberships(:antoine_base), memberships(:valentin_base)], summary.new_memberships.to_a)
  end

  def test_skills_when_user_belongs_to_many_communities
    Membership.create!(user: user = users(:alexis), community: communities(:hep))
    Subscription.create!(user: user, skill: skills(:hep_equations))
    summary = WeeklySummaryJob.new
    assert_emails(1) { summary.perform(memberships(:alexis_base)) }
    assert_equal(["JavaScript", "Programming", "Ruby on Rails"], summary.skills.map(&:name).sort)
  end

  def test_new_private_messages
    summary = WeeklySummaryJob.new
    assert_emails(1) { summary.perform(memberships(:alexis_base)) }
    assert_equal([messages(:antoine_to_alexis)], summary.new_private_messages.to_a)
  end
end
