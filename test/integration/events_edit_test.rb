require 'test_helper'

class EventsEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    @event = add_n_random_events_to(@group, 1)
    install_user_as_group_admin(@user, @group)
    log_in_as(@user)
  end

  test "invalid event edit" do
    get edit_event_path(@event)
    assert_template 'events/edit'
    patch event_path(@event), event: { name: "",
                                        date: Date.today,
                                        start_time: Time.now,
                                        end_time: Time.now + 1.hour,
                                        location: "",
                                        description: "Stuff" }
    assert_template 'events/edit'
  end

  test "valid event edit" do
    get edit_event_path(@event)
    assert_template 'events/edit'
    new_name = "X"
    new_date = Date.today
    new_start = Time.now
    new_end = Time.now + 1.hour
    new_location = "Here"
    new_desc = "Stuff"
    patch_via_redirect event_path(@event), event: { name: new_name,
                                                    date: new_date,
                                                    start_time: new_start,
                                                    end_time: new_end,
                                                    location: new_location,
                                                    description: new_desc }
    assert_not flash.empty?
    assert_template 'events/show'
    # Updated info should be shown
    assert_match new_name, response.body
    assert_match formatted_day(new_date), response.body
    assert_match formatted_time(new_start), response.body
    assert_match formatted_time(new_end), response.body
    assert_match new_location, response.body
    assert_match new_desc, response.body
  end
end
