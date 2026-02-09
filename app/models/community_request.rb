class CommunityRequest < ApplicationRecord
  belongs_to :user
  belongs_to :community, optional: true

  validates_presence_of :name, :description

  scope :pending, -> { where(community_id: nil) }

  def accept
    transaction do
      community = Community.new(name: name, description: description)
      community.update!(permalink: Community.suggest_unique_permalink(community.permalink))
      community.add_moderator(user)
      update!(community: community)
    end
    UserMailer.community_request_accepted(self).deliver
    community
  end
end
