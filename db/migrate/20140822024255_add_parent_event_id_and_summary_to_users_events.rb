class AddParentEventIdAndSummaryToUsersEvents < ActiveRecord::Migration
  def change
    add_column :users_events, :parent_event_id, :integer
    add_column :users_events, :summary, :string
  end
end
