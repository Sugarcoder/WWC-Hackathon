class AddInstructionIdToEvent < ActiveRecord::Migration
  def change
    add_column :events, :instruction_id, :integer
  end
end
