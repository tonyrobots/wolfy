class AddIndexToMoves < ActiveRecord::Migration
  def change
    add_index :moves, :game_id
    add_index :comments, :game_id
    add_index :votes, :voter_id
    add_index :votes, :votee_id
  end
end
