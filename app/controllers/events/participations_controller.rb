class Events::ParticipationsController < ApplicationController
  before_action :find_participation, only: :toggle

  def toggle
    @participation.toggle_presence if current_user.permissions.can_toggle_participations_of_event?(@participation.event)
    render(json: @participation)
  end

  private

  def find_participation
    @event = Event.find(params[:event_id])
    @participation = @event.participations.find(params[:id])
  end
end
