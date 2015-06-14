class AttendancesController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: :create

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

  private

    def attendance_params
      params.require(:attendance).permit(:went, :left, :checked)
    end

    # Tests that the current user is in the group of the event
    def correct_user
      @group = Event.find(params[:event_id]).group
      redirect_to @group unless @group.has_member?(current_user)
    end

end
