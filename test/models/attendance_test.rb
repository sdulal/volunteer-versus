require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
  def setup
    @attendance = attendances(:nick_key)
  end

  test "should be valid" do
    assert @attendance.valid?
  end

  test "attendee should be present" do
    @attendance.attendee = nil
    assert_not @attendance.valid?
  end

  test "event should be present" do
    @attendance.event = nil
    assert_not @attendance.valid?
  end

  test "attendance should be unique" do
    assert_raise do
      @attendance.attendee.attend(@attendance.event)
    end
  end

  test "attendance time should span event time by default" do
    @event = @attendance.event
    assert_equal @event.hours, @attendance.hours
    assert_equal @event.start_time, @attendance.went
    assert_equal @event.end_time, @attendance.left
  end

  test "checked cannot be true until after event" do
    # Preliminary
    @future = attendances(:will_attend)
    assert @future.valid?
    # Try and check off attendance before a future event
    @future.update_attributes(checked: true)
    assert_not @future.valid?
    # Change the event's time to be in past
    @future.event.date = Date.today - 1.day
    assert @future.valid?
  end

  test "start of attendance must be before end of attendance" do
    @attendance.went = Time.now + 2.hours
    @attendance.left = Time.now - 2.hours
    assert_not @attendance.valid?
    @attendance.went = @attendance.left = Time.now
    assert_not @attendance.valid?
  end

  test "checking when proper should change user/group hours" do
    @attendee = @attendance.attendee
    @group = @attendance.group
    @attendance.checked = true
    @attendance.save
    assert_equal 2, @attendee.hours
    assert_equal 2, @group.hours
    assert_equal 2, @attendee.membership_for(@group).hours
    @attendance.checked = false
    @attendance.save
    assert_equal 0, @attendee.hours
    assert_equal 0, @group.hours
    assert_equal 0, @attendee.membership_for(@group).hours
  end

  test "attendance times should be able to change and affect user/group hours" do
    old_went = @attendance.went
    old_left = @attendance.left
    @attendee = @attendance.attendee
    @group = @attendance.group
    @attendance.update_attributes(checked: true)
    assert_equal 2, @attendee.hours
    assert_equal 2, @group.hours
    assert_equal 2, @attendee.membership_for(@group).hours
    @attendance.update_attributes(went: old_went + 1.hour)
    assert_equal 1, @attendee.hours
    assert_equal 1, @group.hours
    assert_equal 1, @attendee.membership_for(@group).hours
    @attendance.update_attributes(left: old_left - (0.5).hour)
    assert_equal 0.5, @attendee.hours
    assert_equal 0.5, @group.hours
    assert_equal 0.5, @attendee.membership_for(@group).hours
  end

end
