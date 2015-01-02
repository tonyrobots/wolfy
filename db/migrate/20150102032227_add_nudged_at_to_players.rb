class AddNudgedAtToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :last_nudged, :datetime, default: "2000-01-01 00:00:00"
  end
end
