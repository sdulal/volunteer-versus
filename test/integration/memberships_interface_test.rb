require 'test_helper'

class MembershipsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    @event = add_n_random_events_to(@group, 5)
  end

  test "joining and quitting group with view changes" do
    get group_path(@group)
    assert_redirected_to login_url
    log_in_as(@user)
    get group_path(@group)
    assert_template 'groups/show'
    assert_select 'form', class: 'new_membership'
    # Accessing members page before joining won't work.
    get group_members_path(@group)
    assert_not flash.empty?
    assert_redirected_to @group
    # Join the group
    assert_difference '@user.groups.count', 1 do
      post memberships_path, group_id: @group.id
    end
    assert_not flash.empty?
    assert_redirected_to @group
    follow_redirect!
    # Seeing more things related to events
    assert_select 'a[href=?]', group_events_path(@group), count: 2
    @group.events.first(5).each do |event|
      assert_select 'a[href=?]', event_path(event), text: event.name
      assert_match formatted_day(event.date), response.body
      assert_match formatted_time(event.start_time), response.body
    end
    # Check that the user is listed on the members' page
    get group_members_path(@group)
    assert_select 'a[href=?]', user_path(@user), text: @user.name
    assert_match formatted_day(@user.membership_for(@group)
                      .created_at), response.body
    # See that the group shows up in user profile
    get groups_user_path(@user)
    assert_template 'users/groups'
    assert_select 'a[href=?]', group_path(@group), text: @group.name
    # Quit the group
    get group_path(@group)
    assert_template 'groups/show'
    assert_select 'form', class: 'edit_membership'
    assert_difference '@user.groups.count', -1 do
      delete membership_path(@user.membership_for(@group))
    end
    assert_redirected_to @group
    follow_redirect!
  end

  test "accessing events in group" do
    # No log in
    get event_path(@event)
    assert_redirected_to login_url
    # No membership
    log_in_as(@user)
    get event_path(@event)
    assert_not flash.empty?
    assert_redirected_to group_events_path(@event.group)
    # Membership
    @user.join(@group)
    get event_path(@event)
    assert_template 'events/show'
  end
end
