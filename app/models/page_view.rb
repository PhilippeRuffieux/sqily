class PageView < ApplicationRecord
  belongs_to :membership

  validates_presence_of :ip_address, :method, :controller, :action, :path
end
