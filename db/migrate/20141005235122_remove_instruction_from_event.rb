class RemoveInstructionFromEvent < ActiveRecord::Migration
  def change
     remove_attachment :events, :instruction
  end
end
