require 'test_helper'

class GroupsDisplayTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    @user.join(@group)
    log_in_as(@user)
  end

  test "index including pagination" do
    get groups_path
    assert_template 'groups/index'
    assert_select 'div.pagination'
    first_page_of_groups = Group.order(hours: :desc).paginate(page: 1)
    first_page_of_groups.each do |group|
      assert_select 'a[href=?]', group_path(group), text: group.name
      assert_match formatted_number(group.hours), response.body
      assert_match formatted_number(group.users.count), response.body
    end
  end

  test "show page as group admin" do
    # Setup
    @group.promote_to_admin(@user)
    add_n_random_events_to(@group, 5)
    # Page elements
    get group_path(@group)
    assert_template 'groups/show'
    assert_select 'title', @group.name + " | Volunteer Versus"
    assert_match @group.name, response.body
    assert_match @group.description, response.body
    assert_select 'a[href=?]', group_events_path(@group), count: 2
    assert_select 'a[href=?]', group_members_path(@group)
    assert_select 'a[href=?]', new_group_event_path(@group),
                                text: "Create event"
    assert_select 'a[href=?]', edit_group_path(@group), text: "Group settings"
    assert_select 'form', class: 'edit_membership'
    @group.events.first(5) do |event|
      assert_match 'a[href=?]', event_path(event), text: event.name
      assert_match event.date.strftime("%B %d, %Y"), response.body
      assert_match event.start_time.strftime("%l:%M %p"), response.body
    end
  end

  test "show page as non-admin" do
    get group_path(@group)
    assert_select 'a[href=?]', new_group_event_path(@group), count: 0
    assert_select 'a[href=?]', edit_group_path(@group), count: 0
  end

  test "show page as non-member" do
    @user.quit(@group)
    add_n_random_events_to(@group, 5)
    get group_path(@group)
    assert_select 'a[href=?]', group_events_path(@group), count: 1
    assert_select 'a[href=?]', event_path(@group.events.first), count: 0
    assert_select 'form', class: 'new_membership'
  end

  test "members page as group admin" do
    @group.promote_to_admin(@user)
    5.times do |n|
      key = "user_" + n.to_s
      user = users(key)
      user.join(@group)
      user.membership_for(@group).hours = rand(1...100)
    end
    get group_members_path(@group)
    assert_template 'groups/members'
    @group.users.each do |member|
      membership = member.membership_for(@group)
      assert_select 'a[href=?]', user_path(member), text: member.name
      assert_match formatted_number(member.hours_for_group(@group)), response.body
      unless member == @user
        assert_select 'a[href=?]', membership_path(membership), text: "Remove"
        assert_select 'a[data-method=?]', 'put'
      end
    end
  end

  test "members page as non-admin" do
    5.times do |n|
      key = "user_" + n.to_s
      user = users(key)
      user.join(@group)
      user.membership_for(@group).hours = rand(1...100)
    end
    get group_members_path(@group)
    assert_template 'groups/members'
    @group.users.each do |member|
      membership = member.membership_for(@group)
      assert_select 'a[href=?]', user_path(member), text: member.name
      assert_match formatted_number(member.hours_for_group(@group)), response.body
      assert_select 'a[href=?]', membership_path(membership), count: 0
      assert_select 'a[data-method=?]', 'put', count: 0
    end
  end

  test "members page as non-member" do
    @user.quit(@group)
    get group_members_path(@group)
    assert_not flash.empty?
    assert_redirected_to @group
  end

  test "edit page as admin" do
    @group.promote_to_admin(@user)
    get edit_group_path(@group)
    assert_template 'groups/edit'
    assert_select '[name=?]', "group[name]"
    assert_select '[name=?]', "group[description]"
    assert_select 'a[data-method=delete]'
  end

  test "edit page as non-admin" do
    # Non-member
    @user.quit(@group)
    get edit_group_path(@group)
    assert_not flash.empty?
    assert_redirected_to @group
    # Regular member
    @user.join(@group)
    get edit_group_path(@group)
    assert_not flash.empty?
    assert_redirected_to @group
  end
end
