class Group < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :events, dependent: :destroy
  has_many :attendances, through: :events
  validates :name, presence: true, length: { maximum: 50 }
  validates :hours, presence: true,
                    numericality: { greater_than_or_equal_to: 0 }

  # Check if the group has a certain user.
  def has_member?(user)
    memberships.exists?(user: user)
  end

  # Get back all the admin memberships.
  def admins
    memberships.where(group: self, admin: true)
  end

  # Check if group has only one admin.
  def has_one_admin?
    admins.count == 1
  end

  # Check if the group has a certain user as admin.
  def has_admin?(user)
    memberships.exists?(user: user, admin: true)
  end

  # Promote a member to admin.
  def promote_to_admin(user)
    if has_member?(user)
      member = memberships.where(user: user).first
      member.admin = true
      member.save
    end
  end
end
