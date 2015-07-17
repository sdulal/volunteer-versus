require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:nick)
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
end
