require 'test_helper'

class HomeLayoutTest < ActionDispatch::IntegrationTest

  test "home page while not logged in" do
    get root_path
    assert_template 'static_pages/home'
    assert_select 'h1', "Volunteer Versus"
    assert_select 'a[href=?]', signup_path
    assert_match "Sign up", response.body
  end

  test "home page while logged in" do
    @user = users(:generic_user)
    @group = groups(:generic_group)
    add_n_random_events_to(@group, 10)
    @user.join(@group)
    @group.events.first(5).each do |event|
      event.update_attributes(date: Date.tomorrow + 1.day)
      @user.attend(event)
    end
    @group.events.last(2).each do |event|
      event.update_attributes(date: Date.yesterday - 1.day)
      @user.attendances.create(event: event, checked: true)
    end
    @group.events[5].update_attributes(date: Date.today)
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_match @user.name, response.body
    assert_match formatted_number(@user.hours), response.body
    assert_match 'Upcoming', response.body
    @user.events.where(date: Date.tomorrow + 1.day).each do |event|
      assert_select 'a[href=?]', event_path(event), event.name
      assert_match event.group.name, response.body
      assert_match formatted_day(event.date), response.body
    end
    assert_match 'Recent', response.body
    @user.events.where(date: Date.yesterday - 1.day).each do |event|
      assert_select 'a[href=?]', event_path(event), event.name
      assert_match event.group.name, response.body
      assert_match formatted_day(event.date), response.body
    end
    assert_select 'a[href=?]', event_path(@group.events[5]), count: 0
  end
end
