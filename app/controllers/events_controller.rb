class EventsController < ApplicationController
  before_action :authenticate_user
  before_action :must_be_membership
  before_action :find_event, only: [:show, :update, :destroy, :register, :unregister]
  before_action :event_must_be_editable, only: [:show, :update]

  def index
    @messages = Message::EventCreated.in_community(current_community)
    @messages = @messages.with_user_participation(current_user) if params[:registered]
  end

  def new
    @event = Event.new(community: current_community,
      registration_finished_at: 6.days.from_now,
      scheduled_at: 7.days.from_now,
      skill_id: params[:skill_id])
  end

  def create
    if (@event = Event.new(creation_event_params)).save
      redirect_to_event_resource
    else
      render(:new)
    end
  end

  def show
  end

  def update
    if @event.update(event_params)
      redirect_to_event_resource
    else
      render(:new)
    end
  end

  def destroy
    CancelEventJob.perform_now(@event) if @event.editable_by?(current_user)
    redirect_to_event_resource
  end

  def register
    @event.register(current_user)
    redirect_to_event_resource
  end

  def unregister
    @event.unregister(current_user)
    redirect_to_event_resource
  end

  private

  def event_params
    params.require(:event).permit(:title, :max_participations, :scheduled_at, :registration_finished_at, :file, :description)
  end

  def creation_event_params
    hash = event_params.merge(user: current_user)
    if (skill_id = params[:event][:skill_id]).present?
      hash[:skill] = current_community.skills.find(skill_id)
    else
      hash[:community] = current_community
    end
    hash
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def redirect_to_event_resource
    if @event.skill
      redirect_to(skill_path(current_community, @event.skill))
    else
      redirect_to(skills_path(current_community))
    end
  end

  def event_must_be_editable
    render_not_found if !@event.editable_by?(current_user)
  end
end
