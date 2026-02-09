class Workspace::Version < ApplicationRecord
  belongs_to :workspace

  validates_presence_of :title, :number

  def previous
    Workspace::Version.where(workspace_id: workspace_id).where("number < ?", number).order(number: :desc).first
  end
end
