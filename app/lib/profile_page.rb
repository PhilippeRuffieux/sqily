class ProfilePage
  attr_reader :membership

  def initialize(membership)
    @membership = membership
  end

  def published_workspaces
    membership.user.workspaces.where(community: membership.community).merge(Workspace::Partnership.writer).published
  end

  def public_workspaces
    published_workspaces.where.not(id: items_of_hidden_workspaces.pluck(:workspace_id)).order(published_at: :desc)
  end

  def completed_subscriptions
    membership.user.subscriptions.in_community(membership.community).completed.order(completed_at: :desc)
  end

  def public_subscriptions
    completed_subscriptions.where.not(id: items_of_hidden_subscriptions.pluck(:subscription_id))
  end

  def public_evaluations
    skill_ids = public_subscriptions.pluck(:skill_id)
    Evaluation.where(user_id: membership.user_id, skill_id: skill_ids).one_version_per_user
  end

  def items_of_hidden_subscriptions
    HiddenProfileItem.where(membership: @membership).where.not(subscription_id: nil)
  end

  def items_of_hidden_workspaces
    HiddenProfileItem.where(membership: @membership).where.not(workspace_id: nil)
  end
end
