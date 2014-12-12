class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  has_many :votes, foreign_key: :voter_id
  has_many :votes_for, class_name: 'Vote', foreign_key: :votee_id
  
  scope :living, -> { where(alive: true) }
  scope :dead, -> { where(alive: false) }
  
  def assign_role(role)
    self.role = role
    self.alive = true
    self.game.log_event "#{self.alias} is a #{self.role}."
    self.save
  end
  
  def kill
    self.game.log_event "#{self.alias} is now DEAD."
    self.alive = false
    self.save
  end
  
  def lynch
    self.game.log_event "#{self.alias} was voted for lynching."
    self.kill
  end
  
  def vote_for(votee)
    if self.voted_for
      self.votes.where(turn:self.game.turn).destroy_all
    end
    @vote = Vote.new
    @vote.game_id = self.game_id
    @vote.voter_id = self.id
    @vote.votee_id = votee.id
    @vote.turn = self.game.turn
    @vote.save
    self.game.count_votes
  end
  
  def voted_for
    begin
      Player.find(self.votes.where(turn:self.game.turn).last.votee_id)
    rescue
      nil
    end
  end
    
end
