class ChangeParentEventIdNameInUsersEvents < ActiveRecord::Migration
  def change
    rename_column :users_events, :parent_event_id, :parent_id
  end
end
