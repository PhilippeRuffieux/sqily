class Community::DeleteJob < ApplicationJob
  queue_as :default

  def perform(community_id)
    if (community = Community.find_by_id(community_id))
      community.skills.roots.each(&method(:destroy_skill))
      community.skills.each(&method(:destroy_skill))  # For communities where duplication failed
      community.invitation_requests.find_each(&:destroy)
      community.invitations.find_each(&:destroy)
      community.messages.find_each { |msg| msg.destroy }
      community.memberships.find_each(&:destroy)
      community.destroy
    end
  end

  def destroy_skill(skill)
    skill.children.each(&method(:destroy_skill))
    skill.evaluations.find_each do |evaluation|
      Homework.where(evaluation_id: evaluation.id).find_each(&:destroy)
      Evaluation::Exam.where(evaluation: evaluation).each(&:destroy)
    end
    skill.messages.find_each { |msg| msg.destroy }
    Message.where(skill_id: skill).find_each(&:destroy)
    Workspace.where(skill_id: skill).find_each(&:destroy)
    skill.destroy
  end
end
