class AddTurnToEventLogs < ActiveRecord::Migration
  def change
    add_column :event_logs, :turn, :integer
  end
end
