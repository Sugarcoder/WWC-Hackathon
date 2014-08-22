class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :events, :addtending_user_count, :attending_user_count
  end
end
