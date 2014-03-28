class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :alias
      t.string :role
      t.boolean :alive
      t.string :last_move

      t.timestamps
    end
  end
end
