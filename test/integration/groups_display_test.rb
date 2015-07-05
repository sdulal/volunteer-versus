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
      # assert_match group.hours, response.body
      # assert_match group.users.count, response.body
    end
  end

  test "show page as group admin" do
    # Setup
    @group.promote_to_admin(@user)
    add_n_random_events_to(@group, n: 5)
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
    add_n_random_events_to(@group, n: 5)
    get group_path(@group)
    assert_select 'a[href=?]', group_events_path(@group), count: 1
    assert_select 'a[href=?]', event_path(@group.events.first), count: 0
    assert_select 'form', class: 'new_membership'
  end
end
