module PermissionsHelper
  def can_edit_current_community?
    admin? || moderator?
  end

  def can_edit_current_community_skills?(skill)
    admin? || moderator? || (current_community.free_skill_creation && skill && skill.creator_id == current_user.id)
  end

  def must_be_authorized_to_edit_current_community_skills
    redirect_to(skills_path(current_community)) unless can_edit_current_community_skills?(@skill)
  end

  def can_delete_message?(message)
    current_user.id == message.from_user_id || moderator?
  end

  def can_edit_message?(message)
    message.from_user_id == current_user.id
  end
end
