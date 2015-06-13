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

end
