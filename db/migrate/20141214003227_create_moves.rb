class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :game_id
      t.string :action
      t.references :player, index: true
      t.integer :turn
      t.integer :target_id

      t.timestamps
    end
  end
end
