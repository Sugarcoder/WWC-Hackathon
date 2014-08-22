class AddWaitingUserCountToEvent < ActiveRecord::Migration
  def change
    add_column :events, :waiting_user_count, :integer, default: 0, null: false
  end
end
