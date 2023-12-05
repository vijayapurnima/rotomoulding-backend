class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.references :run, index: true, foreign_key: true
      t.integer :work_order_id
      t.string :grading
      t.boolean :finish_flag
      t.string :status
      t.timestamps null: false
    end
  end
end
