class AddUserToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :user_id, :integer
    add_foreign_key :products, :user_sessions, column: :user_id
    add_index :products, :user_id
  end
end
