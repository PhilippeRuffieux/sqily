class Skill::DuplicateJob < ApplicationJob
  queue_as :default

  def perform(original, community, user, parent = nil, duplicate_evaluations: false)
    raise ArgumentError.new("Skill #{parent.id} does not belong to community #{community.id}") if parent && parent.community_id != community.id
    raise ArgumentError.new("User #{user.id} does not belong to community #{community.id}") if community.memberships.where(user: user).none?
    (duplicate = original.dup).update!(creator: user, community: community, parent: parent)
    Subscription.create!(user: user, skill: duplicate).complete
    original.tasks.each { |task| task.dup.update!(skill: duplicate) }
    original.evaluations.each { |eval| eval.dup.update!(skill: duplicate, user: user) } if duplicate_evaluations
    original.children.each { |child| perform(child, community, user, duplicate, duplicate_evaluations: duplicate_evaluations) }
    duplicate
  end
end
