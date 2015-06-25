class EventsController < ApplicationController
  before_action :logged_in_user
  before_action :member_of_related_group, only: :show
  before_action :admin_user, only: [:new, :create, :edit, :update, :destroy]

  def index
    @group = Group.find(params[:group_id])
    @events = @group.events.paginate(page: params[:page])
    @show_admin_tools = false
  end

  def new
    @event = Event.new
  end

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

  def show
    @event = Event.find(by_id)
    @group = @event.group
    @attendees = @event.attendees.paginate(page: params[:page])
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
    @group = Event.find(by_id).group
    Event.find(by_id).destroy
    flash[:success] = "Event deleted."
    redirect_to group_events_url(@group)
  end

  private

    def event_params
      params.require(:event).permit(:name, :date, :start_time, :end_time,
                                    :location, :group_id, :description)
    end

    def member_of_related_group
      if params[:event_id]
        @event = Event.find(params[:event_id])
      else
        @event = Event.find(by_id)
      end
      unless @event.group.has_member?(current_user)
        flash[:danger] = "The page you requested is only available to members."
        redirect_to group_events_url(@event.group)
      end
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
