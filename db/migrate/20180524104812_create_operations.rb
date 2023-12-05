class CreateOperations < ActiveRecord::Migration[5.2]
  def change
    create_table :operations do |t|
      t.integer :operation_id
      t.string :operation_name, index: true
      t.timestamps null: false
    end
  end
end
