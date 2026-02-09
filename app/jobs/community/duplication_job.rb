class Community::DuplicationJob < ActiveJob::Base
  queue_as :default

  attr_reader :original_community, :user, :params

  def perform(community_id, user_id, params = {})
    @original_community = Community.find(community_id)
    @user = User.find(user_id)
    @params = params
    @duplicate_evaluations = params.delete(:duplicate_evaluations)
    Community.transaction { copy_community && copy_skills(original_community.skills.roots) && copy_prerequisites }
    community
  rescue ActiveRecord::RecordInvalid
    community
  end

  def copy_community
    community.update!(params)
    community.add_moderator(user)
  end

  def copy_skills(skills, parent = nil)
    skills.each { |skill| Skill::DuplicateJob.perform_now(skill, community, user, parent, duplicate_evaluations: @duplicate_evaluations) }
  end

  def copy_prerequisites
    original_community.skills.each do |skill|
      skill.prerequisites.each do |prerequisite|
        new_prerequisite = prerequisite.dup
        new_prerequisite.update!(
          to_skill: community.skills.find_by_name(prerequisite.to_skill.name),
          from_skill: community.skills.find_by_name(prerequisite.from_skill.name)
        )
      end
    end
  end

  def community
    @community ||= original_community.dup
  end
end
