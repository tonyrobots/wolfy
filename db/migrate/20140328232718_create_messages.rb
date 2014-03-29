class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :game_id
      t.integer :player_id
      t.text :content
      t.text :recipient_list

      t.timestamps
    end
    add_index :messages, :game_id
  end
end
