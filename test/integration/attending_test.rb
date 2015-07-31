require 'test_helper'

class EventsActionTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    @event = add_n_random_events_to(@group, 1)
    install_user_as_group_admin(@user, @group)
    log_in_as(@user)
  end

  test "attendance page as admin" do
    # This test covers the most elements.
    @user.attend(@event)
    @event.update_attributes(date: Date.yesterday)
    get event_attendances_path(@event)
    assert_template 'attendances/index'
    @event.attendees.each do |attendee|
      attendance = attendee.attendance_for(@event)
      assert_select "a[href=?]", user_path(attendee)
      assert_select "a[href=?]", attendance_path(attendance,
                                                  attendance: { checked: true })
      assert_select "a[href=?]", edit_attendance_path(attendance)
    end
  end

  test "attendance page as admin before event ended" do
    @user.attend(@event)
    @event.update_attributes(date: Date.tomorrow)
    get event_attendances_path(@event)
    assert_template 'attendances/index'
    attendance = @user.attendance_for(@event)
    assert_select "a[href=?]", attendance_path(attendance,
                                                attendance: { checked: true }),
                                                count: 0
    assert_select "a[href=?]", edit_attendance_path(attendance), count: 0
  end


  test "attend an event the standard way" do
    assert_difference ['@user.events.count', '@event.attendees.count'], 1 do
      post event_attendances_path(@event), attendee: @user
    end
    assert_redirected_to @event
  end

  test "leave an event the standard way" do
    @user.attend(@event)
    assert_difference ['@user.events.count', '@event.attendees.count'], -1 do
      delete attendance_path(@user.attendance_for(@event))
    end
    assert_redirected_to group_events_url(@event.group)
  end

  test "attend an event with Ajax" do
    get event_path(@event)
    assert_template partial: 'events/_attend'
    assert_difference ['@user.events.count', '@event.attendees.count'], 1 do
      xhr :post, event_attendances_path(@event), attendee: @user
    end
    assert_template partial: 'events/_leave'
  end

  test "leave an event with Ajax" do
    @user.attend(@event)
    get event_path(@event)
    assert_template partial: 'events/_leave'
    assert_difference ['@user.events.count', '@event.attendees.count'], -1 do
      xhr :delete, attendance_path(@user.attendance_for(@event)),
                    attendee: @user
    end
    assert_template partial: 'events/_attend'
  end
end
