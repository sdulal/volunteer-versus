module AttendancesHelper
  # Returns the current user's attendance for a given event.
  def current_user_attendance(event)
    current_user.attendances(:event).first
  end

  # Gets the path that (in combo with method: put) uses
  # the update method of the controller to check attendance.
  def check_path_for(attendance)
    attendance_path(attendance, attendance: { checked: true })
  end

  # Gets the path that (in combo with method: put) uses
  # the update method of the controller to uncheck attendance.
  def uncheck_path_for(attendance)
    attendance_path(attendance, attendance: { checked: false })
  end
end
