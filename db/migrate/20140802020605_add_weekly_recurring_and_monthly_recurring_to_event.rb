class AddWeeklyRecurringAndMonthlyRecurringToEvent < ActiveRecord::Migration
  def up
    rename_column :events, :is_recurring, :is_weekly_recurring
    add_column :events, :is_monthly_recurring, :boolean, default: false, null: false
  end

  def down
    rename_column :events, :is_weekly_recurring, :is_recurring
    remove_column :events, :is_monthly_recurring, :boolean
  end
end
