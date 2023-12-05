class CreateUserSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_sessions do |t|
      t.string :user_name,index: true
      t.string :session_id
      t.timestamps null: false
    end
  end
end
