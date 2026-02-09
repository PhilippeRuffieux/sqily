class InvitationRequest < ActiveRecord::Base
  belongs_to :community

  validates_presence_of :community_id, :email
  validates :email, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/, if: :email
  validates_uniqueness_of :email, scope: :community_id

  after_create :send_notification_to_moderators

  def send_notification_to_moderators
    community.memberships.moderator.each { |membership| UserMailer.invitation_request(self, membership.user).deliver_now }
  end

  def accept!
    Invitation.find_or_create(community, email)
    destroy
  end
end
