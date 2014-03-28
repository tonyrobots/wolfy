class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name
      t.integer :turn
      t.string :state

      t.timestamps
    end
  end
end
