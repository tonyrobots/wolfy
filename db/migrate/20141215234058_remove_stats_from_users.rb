class RemoveStatsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :played_count, :integer, default: 0
    remove_column :users, :wins_count, :integer, default: 0
  end
end
