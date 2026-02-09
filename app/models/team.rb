class Team < ApplicationRecord
  belongs_to :community
  has_many :memberships
  has_many :users, through: :memberships

  validates_presence_of :name

  def update_user_ids(user_ids)
    Membership.where(community: community_id, team_id: id).where.not(user_id: user_ids).update_all(team_id: nil)
    Membership.where(community: community_id, user_id: user_ids).where("team_id != ? OR team_id IS NULL", id).update_all(team_id: id)
  end
end
