class AddDefaultStateToGames < ActiveRecord::Migration
  def change
    change_column_default :games, :state, "Unstarted"
  end
end
