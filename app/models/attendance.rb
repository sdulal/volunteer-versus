class Attendance < ActiveRecord::Base
  before_save :assign_default_times
  before_save :credit_hours, if: "checked_changed?"
  belongs_to :attendee, class_name: "User"
  belongs_to :event
  validates :attendee_id, presence: true
  validates :event_id, presence: true
  validate :check_after_event, if: "checked?"

  def hours
    (left - went) / 1.hour
  end

  private

    def credit_hours
      if checked?
        self.attendee.hours += self.hours
      else
        self.attendee.hours -= self.hours
      end
    end

    def assign_default_times
      self.went = self.event.start_time
      self.left = self.event.end_time
    end

    def check_after_event
      unless (Date.today > event.date) || (Date.today == event.date && 
                                           Time.now.hour >= event.end_time.hour)
        errors.add(:checked, "cannot be done until day of event")
      end
    end
end
