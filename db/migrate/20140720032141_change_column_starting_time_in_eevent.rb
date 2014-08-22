class ChangeColumnStartingTimeInEevent < ActiveRecord::Migration
  def change
    remove_column :events, :starting_time
    remove_column :events, :ending_time
    add_column :events, :starting_time, :datetime
    add_column :events, :ending_time, :datetime
  end
end
