require 'test_helper'

class GroupsManagementTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    install_user_as_group_admin(@user, @group)
  end

  test "group creation" do
    get new_group_url
    assert_redirected_to login_url
    log_in_as(@user)
    get new_group_url
    assert_template 'groups/new'
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
    follow_redirect!
    assert_template 'groups/show'
  end

  test "removing members from group" do
    # Setup for delete
    member = users(:user_1)
    member.join(@group)
    membership = member.membership_for(@group)
    log_in_as(@user)
    # Deletion
    get group_members_path(@group)
    assert_template 'groups/members'
    assert_select 'a[href=?]', membership_path(membership), text: "Remove"
    assert_difference '@group.users.count', -1 do
      delete membership_path(membership)
    end
    assert_not flash.empty?
    assert_redirected_to group_members_path(@group)
    follow_redirect!
    # Check visually that user is not listed as member
    assert_select 'a[href=?]', membership_path(membership), count: 0
    get groups_user_path(member)
    assert_select 'a[href=?]', group_path(@group), count: 0
  end

  test "group edit" do
    # Not logged in
    get edit_group_path(@group)
    assert_redirected_to login_url
    # Logged in as admin
    log_in_as(@user)
    get edit_group_path(@group)
    assert_template 'groups/edit'
    # Proper form elements on page
    assert_select '[name=?]', "group[name]"
    assert_select '[name=?]', "group[description]"
    # Invalid
    patch group_path(@group), group: { name: "",
                                        description: "Sth" }
    assert_template 'groups/edit'
    # Valid
    new_name = "Special"
    new_desc = "Surprise"
    patch group_path(@group), group: { name: new_name,
                                        description: new_desc }
    assert_not flash.empty?
    assert_redirected_to @group
    follow_redirect!
    assert_select 'title', new_name + " | Volunteer Versus"
    assert_match new_name, response.body
    assert_match new_desc, response.body
  end

  test "group destruction" do
    # Logged in as admin
    log_in_as(@user)
    get edit_group_path(@group)
    assert_template 'groups/edit'
    assert_select 'a[data-method="delete"]'
    delete group_path, group: @group
    assert_not flash.empty?
    assert_redirected_to groups_url
    follow_redirect!
    # Group should not be listed anymore anywhere.
    assert_template 'groups/index'
    assert_select 'a[href=?]', group_path(@group), text: @group.name, count: 0
    get groups_user_path(@user)
    assert_template 'users/groups'
    assert_select 'a[href=?]', group_path(@group), text: @group.name, count: 0
  end
end
