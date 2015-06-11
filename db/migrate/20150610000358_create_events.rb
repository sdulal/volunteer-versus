class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.date :date
      t.time :start_time
      t.time :end_time
      t.string :location
      t.text :description
      t.references :group, index: true

      t.timestamps null: false
    end
    add_foreign_key :events, :groups
    add_index :events, [:group_id, :created_at]
  end
end
