class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  
  def assign_role(role)
    self.role = role
    self.alive = true
    self.game.log_event "#{self.alias} is a #{self.role}."
    self.save
  end
  
  def kill
    self.game.log_event "#{self.alias} is now DEAD."
    self.alive = false
    save.save
  end
end
