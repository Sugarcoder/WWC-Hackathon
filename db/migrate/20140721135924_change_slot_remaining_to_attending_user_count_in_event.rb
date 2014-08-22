class ChangeSlotRemainingToAttendingUserCountInEvent < ActiveRecord::Migration
  def change
    rename_column :events, :slot_remaing, :addtending_user_count
  end
end
