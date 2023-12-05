class CreateProductData < ActiveRecord::Migration[5.2]
  def change
    create_table :product_data do |t|
      t.references :product, index: true, foreign_key: true
      t.string :load_data
      t.string :unload_data
      t.string :finish_data
      t.string :fault_data
      t.timestamps null: false
    end
  end
end
