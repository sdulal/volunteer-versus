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
      assert_match event.location, response.body
    end
  end
end
