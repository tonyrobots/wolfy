class AddTargetToComments < ActiveRecord::Migration
  def change
    add_column :comments, :target_id, :integer
  end
end
