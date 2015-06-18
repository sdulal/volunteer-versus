class AttendancesController < ApplicationController
  before_action :logged_in_user
  before_action :member_user
  before_action :admin_user, only: [:edit, :update]

  # Showing all attendances for a particular event.
  # It is intended that events can get checked off in this view.
  def index
    @event = Event.find(params[:event_id])
    @group = @event.group
    @attendees = @event.attendees
    @show_admin_tools = current_user.admin_of?(@event.group) && @event.ended?
  end

  # Carrying out join event.
  def create
    @attendance = Attendance.new(attendee: current_user, event_id: params[:event_id])
    @attendance.save
    flash[:success] = "Joined successfully"
    redirect_to event_url(params[:event_id])
  end

  # A tool that only group admins will use
  def edit
    @attendance = Attendance.find(by_id)
  end

  # Saving above
  def update
    @attendance = Attendance.find(by_id)
    if @attendance.update_attributes(attendance_params)
      flash[:success] = "Updated attendance."
      redirect_to event_attendances_url(@attendance.event)
    else
      render 'edit'
    end
  end

  # Quit event.
  def destroy
    @event = Attendance.find(by_id).event
    Attendance.find(by_id).destroy
    flash[:success] = "Quit successfully!"
    redirect_to @event
  end

  private

    def attendance_params
      params.require(:attendance).permit(:went, :left, :checked)
    end

    # Checks that the current user is in the group of the event
    def member_user
      if params[:event_id]   
        @group = Event.find(params[:event_id]).group
      else
        @group = Attendance.find(params[:id]).group
      end
      redirect_to @group unless @group.has_member?(current_user)
    end

    # Restricts certain actions only to admins of the related group
    def admin_user
      @attendance = Attendance.find(by_id)
      redirect_to @attendance.event unless @attendance.group.has_admin?(current_user)
    end

end
