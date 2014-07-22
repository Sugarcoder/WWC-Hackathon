class CreateUsersEvents < ActiveRecord::Migration
  def change
    create_table :users_events do |t|
      t.integer :user_id
      t.integer :event_id
      t.column :status, :integer, default: 0
      t.timestamps
    end
  end
end
