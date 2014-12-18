class AddUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, default:""
    add_index :users, :username
  end
end
