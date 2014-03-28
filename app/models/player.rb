class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  
  def assign_role(role)
    self.role = role
    self.alive = true
    self.save
  end
    
end
