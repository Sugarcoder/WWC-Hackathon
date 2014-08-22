class RemoveColumnDateFromEvents < ActiveRecord::Migration
  def change
    remove_columns :events, :date
  end
end
