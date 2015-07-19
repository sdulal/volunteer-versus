require 'test_helper'

class EventsAttendancesEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    add_n_random_events_to(@group, 1)
    @event = @group.events.first
    @event.update_attributes(date: Date.yesterday, start_time: Time.now,
                                                    end_time: Time.now + 1.hour)
    @user.join(@group)
    @group.promote_to_admin(@user)
    log_in_as(@user)
  end

  test "event date/time edits should affect attendance taking" do
    5.times do |n|
      key = "user_" + n.to_s
      user = users(key)
      user.join(@event.group)
      user.attend(@event)
      user.attendance_for(@event).update_attributes(checked: true)
    end
    new_name = "Attendance killer"
    new_date = Date.today
    new_start = Time.now
    new_end = Time.now + 1.hour
    new_location = "Here"
    new_desc = "No attendances should be checked for this event."
    patch_via_redirect event_path(@event), event: { name: new_name,
                                                    date: new_date,
                                                    start_time: new_start,
                                                    end_time: new_end,
                                                    location: new_location,
                                                    description: new_desc }
    # No visual paths for checking off.
    get event_attendances_path(@event)
    assert_template 'attendances/index'
    assert_select 'a', text: "Check off", count: 0
    assert_select 'a', text: "Uncheck off", count: 0
    assert_select 'a', text: "Advanced edit", count: 0
  end
end
