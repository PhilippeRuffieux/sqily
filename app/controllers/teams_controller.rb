class TeamsController < ApplicationController
  before_action :find_team, only: [:edit, :update, :delete]

  before_action :must_be_allowed_to_create_teams

  def new
    @team = Team.new
  end

  def create
    @team = current_community.teams.new(team_params)
    if @team.save
      @team.update_user_ids(params[:user_ids])
      redirect_to_return_url
    else
      render(:new)
    end
  end

  def edit
  end

  def update
    if @team.update(team_params)
      @team.update_user_ids(params[:user_ids])
      redirect_to_return_url
    else
      render(:edit)
    end
  end

  def delete
    @team.destroy
    redirect_to_return_url
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end

  def find_team
    @team = current_community.teams.find(params[:id])
  end

  def must_be_allowed_to_create_teams
    head(:forbidden) if !current_membership.permissions.create_teams?
  end
end
