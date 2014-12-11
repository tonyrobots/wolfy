class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  has_many :votes, foreign_key: :voter_id
  has_many :votes_for, class_name: 'Vote', foreign_key: :votee_id
  
  
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
  
  def vote_for(votee)
    @vote = Vote.new
    @vote.game_id = self.game_id
    @vote.voter_id = self.id
    @vote.votee_id = votee.id
    @vote.turn = self.game.turn
    @vote.save
  end
    
end
