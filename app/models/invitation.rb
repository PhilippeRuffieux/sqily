class Invitation < ActiveRecord::Base
  belongs_to :community

  validates_presence_of :community_id, :email, :token
  validates :email, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/, if: :email
  validates_uniqueness_of :email, scope: :community_id

  after_create :send_email
  before_validation :generate_random_token, on: :create

  scope :pending, -> { where(completed_at: nil) }

  def self.find_or_create(community, email)
    if (invitation = Invitation.where(community_id: community.id, email: email).first)
      invitation
    else
      invitation = Invitation.new(community: community, email: email)
      invitation.save ? invitation : nil
    end
  end

  def self.bulk_create(community, emails)
    emails.map { |email| find_or_create(community, email.strip) ? nil : email }.compact
  end

  def complete(user)
    community.add_user(user)
    destroy
  end

  def to_param
    token
  end

  private

  def send_email
    UserMailer.invitation(self).deliver_now
  end

  def generate_random_token
    self.token ||= SecureRandom.hex(32)
  end
end
