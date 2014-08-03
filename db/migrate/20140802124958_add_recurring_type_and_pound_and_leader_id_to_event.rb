class AddRecurringTypeAndPoundAndLeaderIdToEvent < ActiveRecord::Migration
  def up
    remove_column :events, :is_weekly_recurring
    remove_column :events, :is_monthly_recurring
    add_column :events, :recurring_type, :integer, default: 0, null: false
    add_column :events, :pound, :integer, default: 0
    add_column :events, :leader_id, :integer, null: 0
  end

  def down
    add_column :events, :is_weekly_recurring, :boolean
    add_column :events, :is_monthly_recurring, :boolean
    remove_column :events, :recurring_type
    remove_column :events, :pound
    remove_column :events, :leader_id
  end
end
