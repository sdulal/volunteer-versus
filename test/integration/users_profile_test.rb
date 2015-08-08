require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:nick)
    log_in_as(@user)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    @user.last_n_events(5).each do |event|
      assert_match event.name, response.body
      assert_match event.group.name, response.body
      assert_match formatted_day(event.date), response.body
    end
  end

  test "user's groups display" do
    long_desc_group = groups(:generic_group)
    long_desc_group.update_attributes(description: "l" * 141)
    @user.join(long_desc_group)
    get groups_user_path(@user)
    assert_template 'users/groups'
    @user.groups.each do |group|
      assert_select 'a[href=?]', group_path(group), text: group.name
      if (group.description.length <= 140)
        assert_match group.description, response.body
      else
        assert_match group.description[0..139] + "...", response.body
      end
    end
  end

  test "user's events display" do
    get events_user_path(@user)
    assert_template 'users/events'
    @user.events.each do |event|
      assert_select 'a[href=?]', event_path(event), text: event.name
      assert_match event.group.name, response.body
      assert_match formatted_day(event.date), response.body
      assert_match event.description, response.body
    end
  end
end
