class AddDefaultToImageIsFinished < ActiveRecord::Migration
  def change
    change_column :images, :is_receipt, :boolean, default: false, null: false
  end
end
