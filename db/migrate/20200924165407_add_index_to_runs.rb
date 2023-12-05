class AddIndexToRuns < ActiveRecord::Migration[5.2]
  def change
    add_index :runs, :start_date
  end
end