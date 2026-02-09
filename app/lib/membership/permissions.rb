class Membership::Permissions
  attr_reader :membership

  def initialize(membership)
    @membership = membership
  end

  def create_teams?
    membership.moderator?
  end
end
