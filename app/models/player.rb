class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  has_many :votes, foreign_key: :voter_id
  has_many :votes_for, class_name: 'Vote', foreign_key: :votee_id
  has_many :comments, dependent: :delete_all
  
  scope :living, -> { where(alive: true) }
  scope :dead, -> { where(alive: false) }
  
  def assign_role(role)
    self.role = role
    self.alive = true
    self.game.log_event "#{self.alias} is a #{self.role}."
    self.save
  end
  
  def kill
    msg = "#{self.alias} (#{self.role}) is now DEAD."
    self.alive = false
    self.save
    self.game.log_event msg
    self.game.add_message msg
  end
  
  def lynch
    msg = "#{self.alias} was voted for lynching."
    self.game.log_event msg
    self.game.add_message msg
    self.kill
    
  end
  
  def vote_for(votee)
    if self.voted_for
      # delete all previous votes by this person in this game/turn
      self.clear_vote!
    end
    if self.game_id == votee.game_id
      @vote = Vote.new
      @vote.game_id = self.game_id
      @vote.voter_id = self.id
      @vote.votee_id = votee.id
      @vote.turn = self.game.turn
      @vote.save
      self.game.count_votes
    end
  end
  
  def clear_vote!
    self.votes.where(turn:self.game.turn).destroy_all
  end
  
  def voted_for
    begin
      Player.find(self.votes.where(turn:self.game.turn).last.votee_id)
    rescue
      nil
    end
  end
    
end
