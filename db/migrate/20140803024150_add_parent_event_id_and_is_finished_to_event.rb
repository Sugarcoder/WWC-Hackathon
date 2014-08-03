class AddParentEventIdAndIsFinishedToEvent < ActiveRecord::Migration
  def up
    add_column :events, :parent_event_id, :integer
    add_column :events, :is_finished, :boolean
  end

  def down
    remove_column :events, :parent_event_id
    remove_column :events, :is_finished
  end
end
