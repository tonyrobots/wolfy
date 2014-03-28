class AddForeignKeysToPlayers < ActiveRecord::Migration
  def change
    add_reference :players, :user, index: true
    add_reference :players, :game, index: true
  end
end
