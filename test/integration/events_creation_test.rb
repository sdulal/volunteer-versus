require 'test_helper'

class EventManagementTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    install_user_as_group_admin(@user, @group)
    log_in_as(@user)
  end

  test "invalid event creation" do
    get new_group_event_path(@group)
    assert_no_difference '@group.events.count' do
      post group_events_path(@group), event: { name: "",
                                                date: Date.today,
                                                start_time: Time.now,
                                                end_time: Time.now + 1.hour,
                                                location: "",
                                                description: "Stuff" }
    end
    assert_template 'events/new'
  end

  test "valid event creation" do
    get new_group_event_path(@group)
    if late_night?
      new_date = Date.tomorrow
      new_start = Time.new.change(hour: 1)
      new_end = Time.new.change(hour: 2)
    else
      new_date = Date.today
      new_start = Time.now
      new_end = Time.now + 1.hour
    end
    assert_difference '@group.events.count', 1 do
      post group_events_path(@group), event: { name: "X",
                                                date: new_date,
                                                start_time: new_start,
                                                end_time: new_end,
                                                location: "Here",
                                                description: "Stuff" }
    end
    assert_not flash.empty?
    event = assigns(:event)
    assert_redirected_to event
  end
end
