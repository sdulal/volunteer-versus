require 'test_helper'

class EventsActionTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    add_n_random_events_to(@group, 1)
    @event = @group.events.first
    @user.join(@group)
    @group.promote_to_admin(@user)
    log_in_as(@user)
  end

  test "attendance page as admin" do
    @user.attend(@event)
    @event.update_attributes(date: Date.yesterday)
    get event_attendances_path(@event)
    assert_template 'attendances/index'
    @event.attendees.each do |attendee|
      attendance = attendee.attendance_for(@event)
      assert_select "a[href=?]", user_path(attendee)
      assert_select "a", text: "Check off"
      assert_select "a[href=?]", edit_attendance_path(attendance)
    end
  end

  test "attend an event the standard way" do
    assert_difference ['@user.events.count', '@event.attendees.count'], 1 do
      post event_attendances_path(@event), attendee: @user
    end
    assert_redirected_to @event
  end

  test "quit an event the standard way" do
    @user.attend(@event)
    assert_difference ['@user.events.count', '@event.attendees.count'], -1 do
      delete attendance_path(@user.attendance_for(@event))
    end
    assert_redirected_to group_events_url(@event.group)
  end
end
