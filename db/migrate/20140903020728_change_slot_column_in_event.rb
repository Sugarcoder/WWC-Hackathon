class ChangeSlotColumnInEvent < ActiveRecord::Migration
  def change
    change_column :events, :slot, :integer, default: nil,  :null => true
  end
end
