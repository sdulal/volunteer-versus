class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  validates :user, presence: true
  validates :group, presence: true
  validates :hours, presence: true,
                    numericality: { greater_than_or_equal_to: 0 }
end
