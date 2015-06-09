class Group < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  validates :name, presence: true, length: { maximum: 50 }

  def has_member?(user)
    memberships.exists?(user: user)
  end

  def admins
    memberships.where(group: self, admin: true)
  end
end
