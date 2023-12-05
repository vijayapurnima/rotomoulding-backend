class CreateTimers < ActiveRecord::Migration[5.2]
  def change
    create_table :timers do |t|
      t.integer :entity_id
      t.string :entity_type
      t.string :status
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps null: false
    end
  end
end
