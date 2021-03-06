require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @event = events(:festival)
  end

  test "should be valid" do
    assert @event.valid?
  end

  test "name should be present" do
    @event.name = " "
    assert_not @event.valid?
  end

  test "date should be present" do
    @event.date = nil
    assert_not @event.valid?
  end

  test "start time should be present" do
    @event.start_time = nil
    assert_not @event.valid?
  end

  test "end time should be present" do
    @event.end_time = nil
    assert_not @event.valid?
  end

  test "location should be present" do
    @event.location = "    "
    assert_not @event.valid?
  end

  test "description may not be present" do
    @event.description = " " * 21
    assert @event.valid?
  end

  test "group should be present" do
    @event.group_id = nil
    assert_not @event.valid?
  end

  test "start time should be before end time" do
    @event.start_time = @event.end_time + 1.day
    assert_not @event.valid?
  end

  test "changing date/time info should affect attendances" do
    5.times do |n|
      key = "user_" + n.to_s
      user = users(key)
      user.join(@event.group)
      user.attend(@event)
      user.attendance_for(@event).update_attributes(checked: true)
    end
    if late_night?
      new_date = Date.tomorrow
      new_start = Time.new.change(hour: 1)
      new_end = Time.new.change(hour: 2)
    else
      new_date = Date.today
      new_start = Time.now
      new_end = Time.now + 1.hour
    end
    @event.update_attributes(date: new_date,
                              start_time: new_start,
                              end_time: new_end)
    @event.attendances.each do |attendance|
      assert_equal 0, attendance.attendee.hours.round(2)
      assert_not attendance.checked
    end
  end
end
