class PlayersAliveByDefault < ActiveRecord::Migration
  def change
    change_column_default :players, :alive, true
  end
end
