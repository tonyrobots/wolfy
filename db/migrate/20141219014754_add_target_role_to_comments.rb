class AddTargetRoleToComments < ActiveRecord::Migration
  def change
    add_column :comments, :target_role, :string
  end
end
