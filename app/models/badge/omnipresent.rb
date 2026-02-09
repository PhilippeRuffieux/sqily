# TODO: Renommer en participant
class Badge::Omnipresent < Badge
  def self.trigger(participation)
    return unless (community = participation.event.community || participation.event.skill.try(:community))
    return unless (membership = community.memberships.find_by_user_id(participation.user_id))
    return if compute_score(membership) < required_count
    return if where(membership: membership).exists?
    create!(membership: membership)
  end

  def self.trigger_for_last_24h
    Event.where("scheduled_at BETWEEN ? AND ?", 1.day.ago, 6.hours.ago).find_each do |event|
      event.participations.each { |participation| trigger(participation) if participation.confirmed != false }
    end
  end

  def self.required_count
    5
  end

  def self.compute_score(membership)
    Participation.done.in_community(membership.community).where(user: membership.user_id).count
  end

  def self.replay
    Participation.find_each { |msg| trigger(msg) }
  end
end
