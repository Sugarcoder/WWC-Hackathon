class AddAttachmentInstructionToEvents < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.attachment :instruction
    end
  end

  def self.down
    remove_attachment :events, :instruction
  end
end
