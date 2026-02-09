class User::Permissions
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def evaluate_subscription?(subscription)
    if user.id == subscription.user_id && subscription.skill.auto_evaluation
      true
    elsif user.subscriptions.where(skill_id: subscription.skill_id).pluck(:completed_at).first
      true
    else
      user.memberships.find_by_community_id(subscription.skill.community_id).try(:moderator)
    end
  end

  def destroy_partnership?(partnership)
    partnership && partnership.user_id != partnership.workspace.owner_id && (user.id == partnership.user_id || user.id == partnership.workspace.owner_id)
  end

  def read_workspace?(workspace)
    workspace.published_at || user.workspace_partnerships.where(workspace: workspace).exists?
  end

  def update_workspace?(workspace)
    user.workspace_partnerships.writer.where(workspace: workspace).exists?
  end

  def approve_workspace?(workspace)
    !workspace.approved_at? && workspace_reader?(workspace)
  end

  def reject_workspace?(workspace)
    workspace.rejectable? && workspace_reader?(workspace)
  end

  def destroy_workspace?(workspace)
    workspace.owner_id == user.id
  end

  def publish_workspace?(workspace)
    !workspace.published_at? && workspace.approved_at? && (user.owns_workspace?(workspace) || administrate_workspace?(workspace))
  end

  def unpublish_workspace?(workspace)
    workspace.published_at? && (user.owns_workspace?(workspace) || administrate_workspace?(workspace))
  end

  def administrate_workspace?(workspace)
    workspace_reader?(workspace) && workspace_moderator?(workspace)
  end

  def workspace_moderator?(workspace)
    user.memberships.by_community(workspace.community_id).moderator.exists?
  end

  def workspace_reader?(workspace)
    user.workspace_partnerships.reader.where(workspace: workspace).exists?
  end

  def read_community_statistics?(community)
    community.memberships.where(user_id: user.id).limit(1).pluck(:moderator).first
  end

  def promote_subscription?(subscription)
    return false if subscription.completed_at
    user.memberships.find_by_community_id(subscription.skill.community_id).try(:moderator) ||
      user.subscriptions.find_by_skill_id(subscription.skill_id).try(:completed_at)
  end

  def downgrade_subscription?(subscription)
    subscription.completed_at && user.memberships.find_by_community_id(subscription.skill.community_id).try(:moderator)
  end

  def can_edit_event?(event)
    event.user_id == user.id
  end

  def can_toggle_participations_of_event?(event)
    event.scheduled_at <= Time.now && can_edit_event?(event)
  end

  def duplicate_community?(community)
    user.admin || user.memberships.where(community: community).first.try(:moderator)
  end

  def mark_message_as_unread?(message)
    message.to_user_id == user.id
  end

  def read_exam?(exam)
    exam.candidate_id == user.id || exam.examiner_id == user.id
  end

  def can_accept_exam?(exam)
    exam.examiner_id == user.id
  end

  def cancel_exam?(exam)
    exam.persisted? && !exam.is_canceled? && exam.candidate_id == user.id
  end

  def edit_evaluation?(evaluation)
    evaluation.user_id == user.id || user.memberships.by_community(evaluation.skill.community_id).moderator.exists?
  end

  def destroy_evaluation?(evaluation)
    edit_evaluation?(evaluation) && evaluation.destroyable?
  end

  def create_exam_from?(evaluation)
    if (subscription = evaluation.skill.subscriptions.where(user: user).first)
      !subscription.completed_at && Evaluation::Exam.joins(:subscription).where(subscriptions: {user: user}, evaluation_id: evaluation.skill.evaluation_ids).ongoing.none?
    end
  end

  def destroy_skill?(skill)
    skill.destroyable? && user.memberships.where(community_id: skill.community_id).moderator.exists?
  end
end
