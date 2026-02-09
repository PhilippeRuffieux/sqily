class Message::NewSkill < Message
  belongs_to :skill
  validates_presence_of :skill_id

  def self.trigger(skill)
    return if !skill.published_at || !skill.creator
    attributes = {from_user: skill.creator, to_community_id: skill.community_id, skill_id: skill.id}
    where(attributes).first || create!(attributes)
  end
end
