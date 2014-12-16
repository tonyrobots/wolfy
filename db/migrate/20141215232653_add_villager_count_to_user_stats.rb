class AddVillagerCountToUserStats < ActiveRecord::Migration
  def change
    add_column :user_stats, :villager_count, :integer, default: 0
  end
end
