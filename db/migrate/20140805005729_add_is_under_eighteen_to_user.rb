class AddIsUnderEighteenToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_under_eighteen, :boolean
  end
end
