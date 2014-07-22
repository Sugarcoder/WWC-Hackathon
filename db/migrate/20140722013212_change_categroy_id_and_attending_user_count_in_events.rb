class ChangeCategroyIdAndAttendingUserCountInEvents < ActiveRecord::Migration
  def change
    remove_column :events, :category_id
    add_column :events, :category_id, :integer 
    change_column :events, :attending_user_count, :integer, :default => 0, :null => false
  end
end
