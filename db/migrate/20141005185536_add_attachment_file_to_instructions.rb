class AddAttachmentFileToInstructions < ActiveRecord::Migration
  def self.up
    change_table :instructions do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :instructions, :file
  end
end
