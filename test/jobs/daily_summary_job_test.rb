require "test_helper"

class DailySummaryJobTest < ActiveJob::TestCase
  def test_perform
    assert_emails(1) { DailySummaryJob.perform_now(alexis) }
  end

  def test_new_private_messages
    assert_equal([messages(:antoine_to_alexis)], summary(alexis).new_private_messages.to_a)
    assert_emails(1) { DailySummaryJob.perform_now(alexis) }
  end

  def test_new_pinned_messages
    messages(:alexis_to_js).update!(pinned_at: 2.days.ago)
    (to_base = messages(:alexis_to_base)).update!(pinned_at: 1.hour.ago)
    (to_ror = messages(:alexis_file_to_ror)).update!(pinned_at: 1.hour.ago)
    assert_equal([to_ror, to_base], summary(alexis).new_pinned_messages.order(:id).to_a)
    assert_equal([], summary(admin).new_pinned_messages.to_a)

    assert_emails(1) { DailySummaryJob.perform_now(alexis) }
  end

  def test_new_event_messages
    assert_equal([messages(:js_demo_event)], summary(alexis).new_event_messages.to_a)

    assert_emails(1) { DailySummaryJob.perform_now(alexis) }
  end

  def test_upcoming_events
    assert_equal([], summary(alexis).upcoming_events.to_a)

    js_demo.update!(scheduled_at: 2.days.from_now)
    assert_equal([], summary(antoine).upcoming_events.to_a)
    assert_equal([js_demo], summary(alexis).upcoming_events.to_a)

    assert_emails(1) { DailySummaryJob.perform_now(alexis) }
  end

  def test_finished_polls
    poll = polls(:alexis_poll_to_base)
    poll_choices(:choice1).answer(alexis)
    assert_equal([], summary(alexis).finished_polls.to_a)

    poll.update!(finished_at: 1.hour.ago)
    assert_equal([], summary(antoine).finished_polls.to_a)
    assert_equal([poll], summary(alexis).finished_polls.to_a)

    assert_emails(1) { DailySummaryJob.perform_now(alexis) }
  end

  def test_mentionned_messages
    (msg = messages(:alexis_to_base)).update!(text: "@Antoine")
    assert_equal([], summary(alexis).mentionned_messages.to_a)
    assert_equal([msg], summary(antoine).mentionned_messages.to_a)

    assert_emails(1) { DailySummaryJob.perform_now(antoine) }
  end

  def summary(user)
    @summary = DailySummaryJob.new
    @summary.stubs(user: user)
    @summary
  end
end
