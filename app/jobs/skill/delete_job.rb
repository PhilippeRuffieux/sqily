class Skill::DeleteJob < ApplicationJob
  queue_as :default

  def perform(skill_id)
    if (skill = Skill.find_by_id(skill_id))
      Skill.transaction do
        skill.evaluations.find_each do |evaluation|
          Homework.where(evaluation_id: evaluation.id).find_each(&:destroy)
          evaluation.exams.find_each(&:destroy)
          evaluation.destroy
        end
        skill.messages.find_each { |msg| msg.destroy }
        Message.where(skill_id: skill).find_each(&:destroy)
        Workspace.where(skill_id: skill).update_all(skill_id: nil)
        skill.destroy
      end
    end
  end
end
