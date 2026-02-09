class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :community
  belongs_to :team, optional: true
  has_many :badges
  has_many :page_views
  has_many :notifications, foreign_key: :to_membership_id

  validates_presence_of :user_id, :community_id

  scope :moderator, -> { where(moderator: true) }
  scope :by_community, ->(community) { where(community: community) }
  scope :by_team, ->(team) { where(team: team) }
  scope :visible, -> { where(public: true) }

  def unread_messages
    last_read_at ? community.messages.created_after(last_read_at) : community.messages
  end

  def permissions
    @permissions ||= Permissions.new(self)
  end
end
