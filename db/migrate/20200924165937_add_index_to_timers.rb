class AddIndexToTimers < ActiveRecord::Migration[5.2]
  def change
    add_index :timers, :entity_id
    add_index :timers, :entity_type 
  end
end
