class Move < ActiveRecord::Base
  belongs_to :player
  belongs_to :target, :class_name => 'Player', :foreign_key => 'target_id'
  # this doesn't work
  #scope :this_turn, -> { where(turn:self.player.game.turn) }
  
end
