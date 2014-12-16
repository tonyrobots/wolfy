class AddStatsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :played_count, :integer, default: 0
    add_column :users, :wins_count, :integer, default: 0
  end
end
