class AddFieldsToProductData < ActiveRecord::Migration[5.2]
  def change
    add_column :product_data, :cook_data, :string
    add_column :product_data, :cool_data, :string
  end
end
