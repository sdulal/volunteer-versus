require 'test_helper'

class EventsDisplayTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    @user.join(@group)
    log_in_as(@user)
  end

  test "index including pagination" do
    add_n_random_events_to(@group, n: 40)
    get group_events_path(@group)
    assert_template 'events/index'
    assert_select 'div.pagination'
    first_page_of_events = @group.events.paginate(page: 1)
    first_page_of_events.each do |event|
      assert_select 'a[href=?]', event_path(event), text: event.name
      assert_match formatted_day(event.date), response.body
      assert_match formatted_time(event.start_time), response.body
      assert_match formatted_time(event.end_time), response.body
      assert_match CGI::escapeHTML(event.location), response.body
    end
  end

  test "show as admin" do
    # Event specific setup
    add_n_random_events_to(@group, n: 1)
    @event = @group.events.first
    @group.promote_to_admin(@user)
    # Event hasn't passed yet
    @event.update_attributes(date: Date.tomorrow)
    get event_path(@event)
    assert_template 'events/show'
    assert_match formatted_day(@event.date), response.body
    assert_match formatted_time(@event.start_time), response.body
    assert_match formatted_time(@event.end_time), response.body
    assert_match CGI::escapeHTML(@event.location), response.body
    assert_select 'a[href=?]', edit_event_path(@event)
    assert_select 'a[href=?]', event_attendances_path(@event),
                                text: "Check attendances", count: 0
    assert_select 'a[href=?]', event_attendances_path(@event),
                                text: "Join event"
    # Event has passed
    @event.update_attributes(date: Date.yesterday)
    get event_path(@event)
    assert_select 'a[href=?]', event_attendances_path(@event),
                                text: "Check attendances", count: 1
  end

  test "users view on show page including pagination" do
    # Event specific setup
    add_n_random_events_to(@group, n: 1)
    @event = @group.events.first
    @user.attend(@event)
    30.times do |n|
      user = users("user_" + n.to_s)
      user.join(@group)
      user.attend(@event)
    end
    # Check for the first 'page' of attendees info.
    get event_path(@event)
    assert_select 'div.pagination'
    first_page_of_attendees = @event.attendees.paginate(page: 1)
    first_page_of_attendees.each do |attendee|
      assert_select 'a[href=?]', user_path(attendee), attendee.name
    end
  end
end
