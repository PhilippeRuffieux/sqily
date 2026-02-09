class UserMailer < ApplicationMailer
  helper :users, :messages, :notifications

  def invitation_request(invitation_request, moderator)
    @invitation_request, @moderator = invitation_request, moderator
    mail(subject: "Demande d'adhésion en attente", to: moderator.email)
  end

  def invitation(invitation)
    @invitation = invitation
    mail(subject: "Sqily #{invitation.community.name}", to: invitation.email)
  end

  def homework_uploaded(homework)
    @homework = homework
    homework.subscription.user.name
    mail(subject: "Défi en attente de validation", to: homework.evaluation.user.email)
  end

  def homework_rejected(homework)
    @homework = homework
    @message = Message::HomeworkUploaded.find_by_homework_id(homework.id)
    mail(subject: "Des nouvelles de votre défi", to: homework.subscription.user.email)
  end

  def subscription_complete(subscription)
    @subscription = subscription
    mail(subject: "Validation d'une expertise", to: subscription.user.email)
  end

  def password_reset(password_reset)
    @password_reset = password_reset
    mail(to: password_reset.user.email, subject: "Récupération du mot de passe Sqily")
  end

  def weekly_summary(summary)
    @summary = summary
    @membership, @community = summary.membership, summary.membership.community
    mail(to: @membership.user.email, subject: "#{@membership.community.name} résumé hebdomadaire")
  end

  def daily_summary(summary)
    @summary, @user = summary, summary.user
    mail(to: @user.email, subject: "Résumé quotidien")
  end

  def event_reminder(event, user)
    @event, @user = event, user
    mail(to: user.email, subject: "Rappel pour demain")
  end

  def event_cancelled(event, user)
    @event, @user = event, user
    mail(to: user.email, subject: "#{event.title} annulé")
  end

  def waiting_participation_finished(participation)
    @participation = participation
    mail(to: participation.user.email, subject: "Vous êtes inscrit à #{participation.event.title}")
  end

  def new_badge(badge)
    mail(to: (@badge = badge).membership.user.email, subject: "Vous avez obtenu un nouveau badge")
  end

  def community_request_created(community_request)
    @community_request = community_request
    mail(to: "support@sqily.com", subject: "Nouvelle demande de communauté")
  end

  def community_request_accepted(community_request)
    mail(to: (@community_request = community_request).user.email, subject: "Votre communauté a été créée")
  end

  def unread_notifications(membership)
    mail(to: (@membership = membership).user.email, subject: "Nouveautés #{membership.community.name}")
  end
end
