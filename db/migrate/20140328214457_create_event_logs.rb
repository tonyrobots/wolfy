class CreateEventLogs < ActiveRecord::Migration
  def change
    create_table :event_logs do |t|
      t.integer :game_id
      t.text :text
      t.integer :actor
      t.integer :target
      t.string :action

      t.timestamps
    end
    add_index :event_logs, :game_id
  end
end
