class CreateImages < ActiveRecord::Migration
  def up
    create_table :images do |t|
      t.integer :event_id
      t.boolean :is_receipt
      t.timestamps
    end
  end

  def down
    drop_table :images
  end
end
