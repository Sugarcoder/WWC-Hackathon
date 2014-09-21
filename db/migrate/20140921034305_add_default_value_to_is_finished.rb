class AddDefaultValueToIsFinished < ActiveRecord::Migration

  def change
    change_column :events, :is_finished, :boolean, default: false, null: false
  end
  
end
