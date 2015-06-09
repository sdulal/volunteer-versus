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

  def has_admin?(user)
    memberships.exists?(user: user, admin: true)
  end

  def promote_to_admin(user)
    if has_member?(user)
      member = memberships.where(user: user).first
      member.admin = true
      member.save
    end
  end
end
