class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.time :starting_time
      t.time :ending_time
      t.date :date
      t.integer :slot
      t.integer :slot_remaing
      t.string :address
      t.integer :location_id
      t.text :description
      t.boolean :is_recurring
      t.string :category_id

      t.timestamps
    end
  end
end
