class CreateEventsCategories < ActiveRecord::Migration
  def up
    create_table :events_categories do |t|
      t.integer :event_id
      t.integer :category_id
      t.integer :pound

      t.timestamps
    end
  end

  def down
    drop_table :events_categories
  end
end
