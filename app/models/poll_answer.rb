class PollAnswer < ActiveRecord::Base
  belongs_to :choice, class_name: "PollChoice"
  belongs_to :user
end
