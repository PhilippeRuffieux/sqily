class Notification < ApplicationRecord
  TypeScopes.inject self

  belongs_to :to_membership, class_name: :Membership

  scope :unread, -> { where(read_at: nil) }
  scope :latest, -> { order(created_at: :desc) }

  def self.replay
    Notification::BadgeReceived.replay
    Notification::HomeworkApproved.replay
    Notification::HomeworkPending.replay
    Notification::HomeworkRejected.replay
    Notification::MessagePinned.replay
    Notification::VoteReceived.replay
    Notification::Mention.replay
    Notification::PollFinished.replay
    Notification::WorkspaceMessaged.replay
  end
end
