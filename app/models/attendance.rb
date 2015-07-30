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

  # Calculate length of attendance.
  def hours
    (left - went) / 1.hour
  end

  # Get the associated membership model.
  def related_membership
    attendee.membership_for(group)
  end

  private

    # Let attendance initially span event length.
    def assign_default_times
      self.went ||= self.event.start_time
      self.left ||= self.event.end_time
    end


    # Give the user, group and membership hours.
    def credit_hours
      old_attendee_hours = self.attendee.hours
      old_group_hours = self.group.hours
      membership = related_membership
      old_membership_hours = membership.hours
      if checked?
        attendee.update_attributes(hours: (old_attendee_hours + hours))
        group.update_attributes(hours: (old_group_hours + hours))
        membership.update_attributes(hours: (old_membership_hours + hours))
      else
        attendee.update_attributes(hours: (old_attendee_hours - hours))
        group.update_attributes(hours: (old_group_hours - hours))
        membership.update_attributes(hours: (old_membership_hours - hours))
      end
    end

    # Change hours if times change.
    def change_credit
      if (went_changed? || left_changed?) && (checked? && !checked_changed?)
        old_went = went_changed? ? went_change.first : went
        old_left = left_changed? ? left_change.first : left
        old_attendee_hours = self.attendee.hours
        old_group_hours = self.group.hours
        membership = related_membership
        old_membership_hours = membership.hours
        old_credit = (old_left - old_went) / 1.hour
        new_credit = hours
        attendee.update_attributes(hours: (old_attendee_hours - old_credit + new_credit))
        group.update_attributes(hours: (old_group_hours - old_credit + new_credit))
        membership.update_attributes(hours: (old_membership_hours - old_credit + new_credit))
      end
    end

    # Remove any hours if attendance is destroyed.
    def uncredit_hours
      old_attendee_hours = self.attendee.hours
      old_group_hours = self.group.hours
      membership = related_membership
      old_membership_hours = membership.hours
      attendee.update_attributes(hours: (old_attendee_hours - hours))
      group.update_attributes(hours: (old_group_hours - hours))
      membership.update_attributes(hours: (old_membership_hours - hours))
    end

    # Attendances should be checked only after event ends.
    def check_after_event
      unless event.ended?
        errors.add(:checked, "cannot be done until after event has ended")
      end
    end

    # Attendance cannot end before it begins.
    def went_before_left
      unless hours > 0
        errors.add(:went, "must be before left")
      end
    end

    # Attendance has to fall within event times.
    def event_bounds_times
      unless went.between?(event.start_time, event.end_time)
        errors.add(:went, "must be within event times")
      end
      unless left.between?(event.start_time, event.end_time)
        errors.add(:left, "must be within event times")
      end
    end
end
