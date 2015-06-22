class Attendance < ActiveRecord::Base
  after_initialize :assign_default_times
  before_save :credit_hours, if: "checked_changed?"
  before_save :change_credit
  before_destroy :uncredit_hours, if: "checked?"
  belongs_to :attendee, class_name: "User"
  belongs_to :event
  has_one :group, through: :event
  validates :attendee_id, presence: true
  validates :event_id, presence: true
  validate :check_after_event, if: "checked?"
  validate :went_before_left
  validate :event_bounds_times, unless: ["event.nil?"]

  def hours
    (left - went) / 1.hour
  end

  private

    def assign_default_times
      self.went ||= self.event.start_time
      self.left ||= self.event.end_time
    end

    def credit_hours
      old_attendee_hours = self.attendee.hours
      old_group_hours = self.group.hours
      if checked?
        attendee.update_attributes(hours: (old_attendee_hours + hours))
        group.update_attributes(hours: (old_group_hours + hours))
      else
        attendee.update_attributes(hours: (old_attendee_hours - hours))
        group.update_attributes(hours: (old_group_hours - hours))
      end
    end

    def change_credit
      if (went_changed? || left_changed?) && (checked? && !checked_changed?)
        old_went = went_changed? ? went_change.first : went
        old_left = left_changed? ? left_change.first : left
        old_attendee_hours = self.attendee.hours
        old_group_hours = self.group.hours
        old_credit = (old_left - old_went) / 1.hour
        new_credit = hours
        attendee.update_attributes(hours: (old_attendee_hours - old_credit + new_credit))
        group.update_attributes(hours: (old_group_hours - old_credit + new_credit))
      end
    end

    def uncredit_hours
      old_attendee_hours = self.attendee.hours
      old_group_hours = self.group.hours
      attendee.update_attributes(hours: (old_attendee_hours - hours))
      group.update_attributes(hours: (old_group_hours - hours))
    end

    def check_after_event
      unless event.ended?
        errors.add(:checked, "cannot be done until after event has ended")
      end
    end

    def went_before_left
      unless hours > 0
        errors.add(:went, "must be before left")
      end
    end

    def event_bounds_times
      unless went.between?(event.start_time, event.end_time)
        errors.add(:went, "must be within event times")
      end
      unless left.between?(event.start_time, event.end_time)
        errors.add(:left, "must be within event times")
      end
    end
end
