class AddNightStartToGames < ActiveRecord::Migration
  def change
    add_column :games, :nightstart, :boolean, default:true
  end
end
