class CreateRuns < ActiveRecord::Migration[5.2]
  def change
    create_table :runs do |t|
      t.integer :run_number,index: true
      t.integer :arm_id,index:true
      t.date :start_date
      t.string :status
      t.timestamps null: false
    end
  end
end
