# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def invitation_request
    UserMailer.invitation_request(InvitationRequest.last, User.last)
  end

  def invitation
    UserMailer.invitation(Invitation.last)
  end

  def homework_uploaded
    UserMailer.homework_uploaded(Homework.last)
  end

  def homework_rejected
    UserMailer.homework_rejected(Homework.where("rejected_at IS NOT NULL").last)
  end

  def subsciption_complete
    UserMailer.subscription_complete(Subscription.where.not(completed_at: nil).last)
  end

  def password_reset
    UserMailer.password_reset(PasswordReset.last)
  end

  def weekly_summary_alexis
    weekly_summary(User.where("email LIKE 'alexis@%'").first)
  end

  def weekly_summary_antoine
    weekly_summary(User.where("email LIKE 'antoine@%'").first)
  end

  def daily_summary_alexis
    daily_summary(User.where("email LIKE 'alexis@%'").first)
  end

  def daily_summary_antoine
    daily_summary(User.where("email LIKE 'alexis@%'").first)
  end

  def waiting_participation_finished
    UserMailer.waiting_participation_finished(Participation.last)
  end

  def new_badge
    UserMailer.new_badge(Badge.last)
  end

  def community_request_created
    UserMailer.community_request_created(CommunityRequest.last)
  end

  def community_request_accepted
    UserMailer.community_request_accepted(CommunityRequest.where.not(community_id: nil).last)
  end

  def notifications_to_alexis
    UserMailer.unread_notifications(User.where("email LIKE 'alexis@%'").first.memberships.first)
  end

  def notifications_to_antoine
    UserMailer.unread_notifications(User.where("email LIKE 'antoine@%'").first.memberships.first)
  end

  private

  def daily_summary(user)
    summary = DailySummaryJob.new
    summary.user = user
    UserMailer.daily_summary(summary)
  end

  def weekly_summary(user)
    summary = WeeklySummaryJob.new(user.memberships.first)
    UserMailer.weekly_summary(summary)
  end
end
