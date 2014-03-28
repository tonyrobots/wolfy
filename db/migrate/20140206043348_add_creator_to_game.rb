class AddCreatorToGame < ActiveRecord::Migration
  def change
    add_column :games, :creator_id, :integer
  end
end
