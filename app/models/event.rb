class Event < ActiveRecord::Base
  after_update :update_attendances
  belongs_to :group
  has_many :attendances, dependent: :destroy
  has_many :attendees, through: :attendances
  default_scope -> { order(date: :desc) }
  validates :name, presence: true
  validates :date, presence: true
  validates :location, presence: true
  validates :group_id, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :start_before_end, unless: ["start_time.nil?", "end_time.nil?"]
  attr_accessor :hours


  def hours
    (end_time - start_time) / 1.hours
  end

  def has_attendee?(attendee)
    attendees.exists?(attendee.id)
  end

  def ended?
    (Date.today > date) || (Date.today == date &&
                            Time.now.hour >= end_time.hour)
  end

  private

    def update_attendances
      if date_changed? || start_time_changed? || end_time_changed?
        remove_checks = false
        new_date = changes[:date] ? changes[:date].second : date
        new_start = changes[:start_time] ? changes[:start_time].second : start_time
        new_end = changes[:end_time] ? changes[:end_time].second : end_time
        if new_date.future?
          remove_checks = true
        elsif new_end.future? && (new_date == Date.today)
          remove_checks = true
        end
        attendances.each do |attendance|
          new_checked = remove_checks ? false : attendance.checked
          attendance.update_attributes(went: new_start, left: new_end,
                                        checked: new_checked)
        end
      end
    end

    # Validates that the event starts before it ends.
    def start_before_end
      if start_time == end_time
        errors.add(:end_time, "cannot be the same as start time")
      end
      if start_time > end_time
        errors.add(:start_time, "cannot be after end time")
      end
    end
end
