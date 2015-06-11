class Attendance < ActiveRecord::Base
  belongs_to :attendee, class_name: "User"
  belongs_to :event
  validates :attendee_id, presence: true
  validates :event_id, presence: true

end
