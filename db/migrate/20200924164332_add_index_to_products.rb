class AddIndexToProducts < ActiveRecord::Migration[5.2]
  def change
    add_index :products, :work_order_id
    add_index :products, :status
    add_index :products, :finish_flag
  end
end
