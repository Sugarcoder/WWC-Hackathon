class CreateInstructions < ActiveRecord::Migration
  def change
    create_table :instructions do |t|
      t.string :description

      t.timestamps
    end
  end
end
