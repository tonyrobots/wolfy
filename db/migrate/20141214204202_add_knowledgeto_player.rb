class AddKnowledgetoPlayer < ActiveRecord::Migration
  def change
    add_column :players, :knowledge, :integer, array: true, default: []
  end
end
