class Message::Upload < Message
  include AwsFileStorage

  validates_presence_of :file_node
end
