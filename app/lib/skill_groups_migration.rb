class SkillGroupsMigration
  def self.migrate
    migrate_groups
    migrate_prerequisites
  end

  def self.migrate_groups
    Skill.distinct.order(:community_id, :group_name).pluck(:community_id, :group_name).each do |(community_id, group_name)|
      next if group_name.blank?
      skill_name = group_name.strip
      if !Skill.where(community_id: community_id, name: skill_name).exists?
        parent = Skill.create!(community_id: community_id, name: skill_name, description: skill_name, published_at: Time.now)
        Skill.where(community: community_id, group_name: group_name).update_all(parent_id: parent.id)
        parent.children.each do |child|
          child.subscriptions.each do |child_subscription|
            parent_subscription = parent.subscribe(child_subscription.user)
            scope = Subscription.where(skill_id: parent.child_ids, user: child_subscription.user)
            if scope.count == scope.completed.count
              parent_subscription.complete(nil)
            end
          end
        end
      end
    end
  end

  def self.migrate_prerequisites
    Prerequisite.find_each do |prerequisite|
      from_skill, to_skill = prerequisite.from_skill, prerequisite.to_skill
      if from_skill.parent_id != to_skill.parent_id
        from_parent = from_skill.parent || from_skill
        to_parent = to_skill.parent || to_skill
        if Prerequisite.where(from_skill: from_parent, to_skill: to_parent).exists?
          prerequisite.destroy
        else
          prerequisite.update!(from_skill: from_parent, to_skill: to_parent)
        end
      end
    end
  end
end
