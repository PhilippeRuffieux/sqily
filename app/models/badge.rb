class Badge < ApplicationRecord
  belongs_to :membership

  # Disable email notifications since we have a notification stream
  # after_create :send_email_notification

  def self.classes
    [
      Badge::Advisor,
      Badge::Creator,
      Badge::Explorer,
      Badge::Master,
      Badge::Messenger,
      Badge::Omnipresent,
      Badge::Participant,
      Badge::Partner,
      Badge::Producer,
      Badge::Professor,
      Badge::Savant,
      Badge::Specialist
    ]
  end

  def self.replay
    classes.each(&:replay)
  end

  def self.label
    name.split("::").last.downcase
  end

  def self.description
    I18n.t("activerecord.attributes.badges/#{label}.description", count: required_count)
  end

  def self.image_path
    "badges/#{label}.svg"
  end

  def description
    self.class.description
  end

  def image_path
    self.class.image_path
  end

  def send_email_notification
    UserMailer.new_badge(self).deliver_now
  end
end
