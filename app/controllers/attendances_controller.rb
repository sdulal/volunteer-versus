class AttendancesController < ApplicationController
  before_action :logged_in_user

  # View everyone attending the event
  def index
    
  end

  # Saying that one is going
  def new
  end

  # Carrying out above action
  def create
    @attendance = Attendance.new(attendee: current_user, event_id: params[:event_id])
    @attendance.save
    flash[:success] = "Joined successfully"
    redirect_to event_url(params[:event_id])
  end

  # A tool that only group admins will use
  def edit
  end

  # Saving above
  def update
  end

  # Quit event/admin deletes from event
  def destroy
    Attendance.find(by_id).destroy
    flash[:success] = "Quit successfully!"
    redirect_to :back
  end

end
