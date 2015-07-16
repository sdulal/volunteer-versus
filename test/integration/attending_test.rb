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
