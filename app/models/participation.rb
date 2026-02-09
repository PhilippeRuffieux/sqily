class Participation < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  scope :in_community, ->(community) { joins(:event).where("events.community_id = ? OR events.skill_id IN (?)", community, community.skills.ids) }
  scope :done, -> { joins(:event).where("scheduled_at <= ?", Time.now) }

  def toggle_presence
    if confirmed == true
      update_attribute(:confirmed, false)
    elsif confirmed == false
      update_attribute(:confirmed, nil)
    else
      update_attribute(:confirmed, true)
    end
  end
end
