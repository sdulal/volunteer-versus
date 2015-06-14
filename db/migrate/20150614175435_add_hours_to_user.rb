class AddHoursToUser < ActiveRecord::Migration
  def change
    add_column :users, :hours, :decimal, null: false, default: 0
  end
end
