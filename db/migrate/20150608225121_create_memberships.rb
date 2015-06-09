class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :user, index: true
      t.references :group, index: true
      t.boolean :admin, default: false

      t.timestamps null: false
    end
    add_foreign_key :memberships, :users
    add_foreign_key :memberships, :groups
  end
end
