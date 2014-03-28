class EventLog < ActiveRecord::Base
  belongs_to :game
  default_scope order('created_at DESC')
  
  def log(text)
    self.message = text
    self.save
  end
end
