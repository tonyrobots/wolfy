class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :game_id
      t.integer :voter_id
      t.integer :votee_id
      t.integer :turn

      t.timestamps
    end
    add_index :votes, :game_id
  end
end
