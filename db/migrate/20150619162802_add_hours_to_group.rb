class AddHoursToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :hours, :decimal, null: false, default: 0
  end
end
