class PrerequisitesController < ApplicationController
  before_action :authenticate_user
  before_action :find_skill
  before_action :must_be_authorized_to_edit_current_community_skills
  before_action :find_prerequisite, only: [:toggle_mandatory, :destroy]

  def create
    @prerequisite = @skill.prerequisites.create!(prerequisite_attributes)
    render(layout: false)
  end

  def toggle_mandatory
    @prerequisite.toggle!(:mandatory)
    head(:ok)
  end

  def destroy
    @skill.prerequisites.find(params[:id]).destroy
    head(:ok)
  end

  private

  def find_skill
    @skill = current_community.skills.find(params[:skill_id])
  end

  def prerequisite_attributes
    params.require(:prerequisite).permit(:from_skill_id)
  end

  def find_prerequisite
    @prerequisite = @skill.prerequisites.find(params[:id])
  end
end
