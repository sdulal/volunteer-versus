class AddHoursToMembership < ActiveRecord::Migration
  def change
    add_column :memberships, :hours, :decimal, null: false, default: 0
  end
end
