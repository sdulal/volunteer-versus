require 'test_helper'

class AttendancesEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    @event = add_n_random_events_to(@group, 1)
    install_user_as_group_admin(@user, @group)
    log_in_as(@user)
    @user.attend(@event)
  end


  test "attendance edit page" do
    @event.update_attributes(date: Date.yesterday)
    get edit_attendance_path(@user.attendance_for(@event))
    assert_template 'attendances/edit'
    assert_select 'select[name*=?]', 'went', count: 2
    assert_select 'select[name*=?]', 'left', count: 2
    assert_select '[name=?]', 'attendance[checked]'
  end

  test "invalid attendance edit" do
    @attendance = @user.attendance_for(@event)
    get edit_attendance_path(@attendance)
    # Attendance out of bounds
    @event.update_attributes(date: Date.yesterday)
    bad_went = @event.start_time - 1.hour
    bad_left = @event.end_time + 1.hour
    patch attendance_path(@attendance), attendance: { went: bad_went,
                                                      left: bad_left,
                                                      checked: false }
    assert_template 'attendances/edit'
  end

  test "valid attendance edit" do
    @attendance = @user.attendance_for(@event)
    get edit_attendance_path(@attendance)
    # Attendance out of bounds
    @event.update_attributes(date: Date.yesterday)
    new_went = @event.start_time + 15.minutes
    new_end = @event.end_time - 15.minutes
    patch attendance_path(@attendance), attendance: { went: new_went,
                                                      left: new_end,
                                                      checked: true }
    assert_redirected_to event_attendances_path(@event)
    follow_redirect!
    assert_template 'attendances/index'
    assert_select "a[href=?]", attendance_path(@attendance,
                                                attendance: { checked: false })
  end
end
