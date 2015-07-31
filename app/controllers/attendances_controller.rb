class AttendancesController < ApplicationController
  before_action :logged_in_user
  before_action :member_user
  before_action :admin_user, only: [:edit, :update]
  before_action :event_ended, only: [:edit, :update]

  # Showing all attendances for a particular event.
  # It is intended that events can get checked off in this view.
  def index
    @event = Event.find(params[:event_id])
    @group = @event.group
    @attendees = @event.attendees.paginate(page: params[:page])
    @show_admin_tools = current_user.admin_of?(@event.group) && @event.ended?
  end

  # Carrying out join event.
  def create
    @event = Event.find(params[:event_id])
    current_user.attend(@event)
    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
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
    current_user.leave(@event)
    respond_to do |format|
      format.html { redirect_to group_events_url(@event.group) }
      format.js
    end
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
      unless @attendance.group.has_admin?(current_user)
        flash[:danger] = "You must be an admin of the group."
        redirect_to @attendance.event
      end
    end

    # Checks that the event has ended
    def event_ended
      @event = Attendance.find(by_id).event
      unless @event.ended?
        flash[:danger] = "Cannot edit attendances until event ends."
        redirect_to event_attendances_url(@event)
      end
    end

end
