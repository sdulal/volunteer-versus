class EventsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: [:new, :create, :edit, :update, :destroy]

  def index
    @group = Group.find(params[:group_id])
    @events = @group.events.all
  end

  def new
    @event = Event.new
    @event.group_id = Group.find(params[:group_id])
  end

  def create
    @event = Event.create(event_params)
    if @event.save
      flash[:success] = "Event created!"
      # The user should become a leader/owner of event.
      redirect_to @event
    else
      redirect_to new_group_event_url
    end
  end

  def show
    @event = Event.find(by_id)
    @attendees = @event.attendees
  end

  def edit
    @event = Event.find(by_id)
  end

  def update
    @event = Event.find(by_id)
    if @event.update_attributes(event_params)
      flash[:success] =  "Event updated"
      redirect_to @event
    else
      render 'edit'
    end
  end

  def destroy
    Event.find(by_id).destroy
    flash[:success] = "Event deleted."
    redirect_to user_url
  end

  private

    def event_params
      params.require(:event).permit(:name, :date, :start_time, :end_time,
                                    :location, :group_id, :description)
    end

    def admin_user
      if (params[:group_id])
        @group = Group.find(params[:group_id])
      else
        @group = Event.find(by_id).group
      end
      redirect_to @group unless @group.has_admin?(current_user)
    end
end
