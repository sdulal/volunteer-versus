require 'test_helper'

class EventsDisplayTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    add_n_random_events_to(@group, n: 1)
    @event = @group.events.first
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

  test "new page" do
    get new_group_event_path(@group)
    assert_not flash.empty?
    assert_redirected_to @group
    @group.promote_to_admin(@user)
    get new_group_event_path(@group)
    assert_template 'events/new'
    # Checking that the partial has certain fields
    assert_template partial: 'events/_fields'
    assert_select '[name=?]', 'event[name]'
    assert_select 'label[for=?]', 'event_date'
    assert_select 'label[for=?]', 'event_start_time'
    assert_select 'label[for=?]', 'event_end_time'
    assert_select '[name=?]', 'event[location]'
    assert_select '[name=?]', 'event[description]'
  end

  test "show as admin" do
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

  test "show as non-admin" do
    # Event hasn't passed yet
    @event.update_attributes(date: Date.tomorrow)
    get event_path(@event)
    assert_template 'events/show'
    assert_select 'a[href=?]', edit_event_path(@event), count: 0
    # Event has passed
    @event.update_attributes(date: Date.yesterday)
    get event_path(@event)
    assert_select 'a[href=?]', event_attendances_path(@event),
                                text: "Check attendances", count: 0
  end

  test "users view on show page including pagination" do
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

  test "edit page" do
    # Must be an admin to access the page.
    get edit_event_path(@event)
    assert_not flash.empty?
    assert_redirected_to @event
    @group.promote_to_admin(@user)
    get edit_event_path(@event)
    assert_template 'events/edit'
    assert_template partial: 'events/_fields'
  end
end
