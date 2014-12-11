class SetDefaultTurnToZero < ActiveRecord::Migration
  def change
    change_column_default :games, :turn, 0
  end
end
