require 'test_helper'

class GroupsManagementTest < ActionDispatch::IntegrationTest
  # Goals:
  # Test group creation page.
  # Test group page
  # Test group editing page.
  # Test group members page.
  # Test group events page.

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
  end

  test "group creation" do
    get new_group_url
    assert_redirected_to login_url
    log_in_as(@user)
    get new_group_url
    assert_template 'groups/new'
    # Proper form elements on page
    assert_select '[name=?]', "group[name]"
    assert_select '[name=?]', "group[description]"
    # Invalid
    assert_no_difference 'Group.count' do
      post groups_path, group: { name: "",
                                  description: "" }
    end
    assert_template 'groups/new'
    # Valid
    assert_difference 'Group.count', 1 do
      post groups_path, group: { name: "Group",
                                  description: "Stuff" }
    end
    group = assigns(:group)
    assert_redirected_to group
  end

  test "index including pagination" do
    log_in_as(@user)
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
    # Proper membership
    log_in_as(@user)
    @user.join(@group)
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
    assert_select 'a[href=?]', new_group_event_path(@group), text: "Create event"
    assert_select 'a[href=?]', edit_group_path(@group), text: "Group settings"
    assert_select 'form', class: 'edit_membership'
    @group.events.first(5) do |event|
      assert_match 'a[href=?]', event_path(event), text: event.name
      assert_match event.date.strftime("%B %d, %Y"), response.body
      assert_match event.start_time.strftime("%l:%M %p"), response.body
    end
  end

  test "show page as non-admin" do
  end
end
