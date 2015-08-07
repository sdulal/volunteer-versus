require 'test_helper'

class AttendancesIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    @event = add_n_random_events_to(@group, 1)
    install_user_as_group_admin(@user, @group)
    log_in_as(@user)
  end

  # This test covers the most elements.
  test "attendance page as admin including pagination" do
    # Bring in multiple attendees
    @user.attend(@event)
    30.times do |n|
      user = users("user_" + n.to_s)
      user.join(@group)
      user.attend(@event)
    end
    @event.update_attributes(date: Date.yesterday)
    get event_attendances_path(@event)
    assert_template 'attendances/index'
    assert_template partial: 'attendances/_attendee'
    assert_select 'div.pagination'
    # Check for the first 'page' of attendees info.
    first_page_of_attendees = @event.attendees.paginate(page: 1)
    first_page_of_attendees.each do |attendee|
      attendance = attendee.attendance_for(@event)
      assert_select 'a[href=?]', user_path(attendee), attendee.name
      assert_select "a[href=?]", attendance_path(attendance,
                                                attendance: { checked: true })
      assert_select "a[href=?]", edit_attendance_path(attendance)
    end
  end

  test "attendance page as admin before event ended" do
    @user.attend(@event)
    @event.update_attributes(date: Date.tomorrow)
    get event_attendances_path(@event)
    attendance = @user.attendance_for(@event)
    assert_select "a[href=?]", attendance_path(attendance,
                                                attendance: { checked: true }),
                                                count: 0
    assert_select "a[href=?]", edit_attendance_path(attendance), count: 0
  end

  test "attendance page as non-admin" do
    @user.membership_for(@group).update_attributes(admin: false)
    @user.attend(@event)
    @event.update_attributes(date: Date.yesterday)
    get event_attendances_path(@event)
    attendance = @user.attendance_for(@event)
    assert_select "a[href=?]", attendance_path(attendance,
                                                attendance: { checked: true }),
                                                count: 0
    assert_select "a[href=?]", edit_attendance_path(attendance), count: 0
  end
end
