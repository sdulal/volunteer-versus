class Attendance < ActiveRecord::Base
  before_save :assign_default_times
  belongs_to :attendee, class_name: "User"
  belongs_to :event
  validates :attendee_id, presence: true
  validates :event_id, presence: true
  validate :check_after_event

  def hours
    (left - went) / 1.hour
  end

  private

    def assign_default_times
      self.went = self.event.start_time
      self.left = self.event.end_time
    end

    def check_after_event
      if checked? && (DateTime.now < event.date.to_datetime + event.end_time.seconds)
        errors.add(:checked, "cannot be done until day of event")
      end
    end
end
