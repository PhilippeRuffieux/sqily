class Notification::Mention < Notification
  belongs_to :message

  Message.after_save { Notification::Mention.trigger(self) }

  def self.split(string)
    array = string.split("@")[1..] if string
    array ? array.map { |str| str.split(/\s/).first }.delete_if { |str| !str || !str.match(/\b/) } : []
  end

  def self.trigger(message)
    community = message.community
    split(message.text).each do |name|
      User.in_community(community).name_starts_with(name).order(Arel.sql("CHAR_LENGTH(name) DESC")).each do |user|
        if message.text.include?("@#{user.name}")
          if (membership = community.memberships.find_by_user_id(user.id))
            if !where(message: message, to_membership: membership).exists?
              create!(message: message, to_membership: membership, created_at: message.created_at)
            end
          end
        end
      end
    end
  end

  def self.replay
    Message.find_each { |msg| trigger(msg) }
  end
end
