class EventsController < ApplicationController
  before_action :logged_in_user
  before_action :member_of_related_group, only: :show
  before_action :admin_user, only: [:new, :create, :edit, :update, :destroy]

  # Listing all the events for a group.
  def index
    @group = Group.find(params[:group_id])
    @events = @group.events.paginate(page: params[:page])
    @show_admin_tools = false
  end

  # Set up form for new event.
  def new
    @event = Event.new
  end

  # Create a new event.
  def create
    @group = Group.find(params[:group_id])
    @event = @group.events.build(event_params)
    if @event.save
      flash[:success] = "Event created!"
      redirect_to @event
    else
      render 'new'
    end
  end

  # Showing a specific event.
  def show
    @event = Event.find(by_id)
    @group = @event.group
    @attendees = @event.attendees.paginate(page: params[:page])
  end

  # Edit a certain event.
  def edit
    @event = Event.find(by_id)
  end

  # Update a certain event.
  def update
    @event = Event.find(by_id)
    if @event.update_attributes(event_params)
      flash[:success] =  "Event updated"
      redirect_to @event
    else
      render 'edit'
    end
  end

  # Delete a certain event.
  def destroy
    @group = Event.find(by_id).group
    Event.find(by_id).destroy
    flash[:success] = "Event deleted."
    redirect_to group_events_url(@group)
  end

  private

    # Limit what parameters of event can be modified.
    def event_params
      params.require(:event).permit(:name, :date, :start_time, :end_time,
                                    :location, :group_id, :description)
    end

    # Check that the current user is a group member.
    def member_of_related_group
      @event = Event.find(by_id)
      unless @event.group.has_member?(current_user)
        flash[:danger] = "The page you requested is only available to members."
        redirect_to group_events_url(@event.group)
      end
    end

    # Limit to group admins.
    def admin_user
      new_or_create = !!params[:group_id]
      if new_or_create
        @group = Group.find(params[:group_id])
      else
        @event = Event.find(by_id)
        @group = @event.group
      end
      unless @group.has_admin?(current_user)
        flash[:danger] = "The page you requested is only available to admins."
        if new_or_create
          redirect_to @group
        else
          redirect_to @event
        end
      end
    end
end
