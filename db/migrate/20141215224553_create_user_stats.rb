class CreateUserStats < ActiveRecord::Migration
  def change
    create_table :user_stats do |t|
      t.integer :played_count, default: 0
      t.integer :wins_count, default: 0
      t.integer :survived_count, default: 0
      t.belongs_to :user, null:false
      t.integer :wolf_count, default: 0
      t.integer :seer_count, default: 0
      t.integer :angel_count, default: 0
      t.integer :illusionist_count, default: 0
    end
  end
end
