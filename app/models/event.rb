class Event < ActiveRecord::Base
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
    attendees.exists?(attendee)
  end

  def ended?
    (Date.today > date) || (Date.today == date && 
                            Time.now.hour >= end_time.hour)
  end

  private

    # Validates that the event starts before it ends.
    def start_before_end
      if start_time > end_time
        errors.add(:start_time, "cannot be after end time")
      end
    end
end
