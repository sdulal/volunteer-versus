require 'test_helper'

class EventsActionTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    add_n_random_events_to(@group, 1)
    @event = @group.events.first
    @user.join(@group)
    log_in_as(@user)
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
