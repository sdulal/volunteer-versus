module AttendancesHelper
  def current_user_attendance(event)
    current_user.attendances(:event).first
  end
end
