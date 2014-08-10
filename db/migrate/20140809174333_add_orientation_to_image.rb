class AddOrientationToImage < ActiveRecord::Migration
  def change
    add_column :images, :orientation, :string
  end
end
