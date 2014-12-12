class EventLog < ActiveRecord::Base
  belongs_to :game
  
  def log(text)
    self.message = text
    self.save
  end
end
