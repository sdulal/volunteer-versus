class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.integer :attendee_id
      t.integer :event_id
      t.boolean :checked, default: false
      t.time :went
      t.time :left

      t.timestamps null: false
    end
    add_index :attendances, :attendee_id
    add_index :attendances, :event_id
    add_index :attendances, [:attendee_id, :event_id], unique: true
  end
end
