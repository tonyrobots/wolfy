class Game < ActiveRecord::Base
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  has_many :event_logs, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  def advance_turn
   self.turn += 1
    if is_day?
      #@vote_counter = Vote_counter.new(self.player_list)
      self.state = "day"
    elsif is_night?
      self.state = "night"
      for player in self.players
        player.last_move = ""
      end
    end
    self.save
    log_event "It is now turn #{self.turn} (#{self.state})."
  end
  
  def assign_roles
    #probably make this protected somehow so only self can run, also should confirm correct conditions (e.g. turn ==0)
    #update these counts later so they are based on @rules hash
    #make role an object?
    # werewolf_count = (self.players.count/self.rules[:wolf_ratio]).round
    # seer_count = (self.players.count/self.rules[:seer_ratio]).round
    # angel_count = (self.players.count/self.rules[:angel_ratio]).round
    werewolf_count = (self.players.count/5.0).round
    seer_count = (self.players.count/10.0).round
    angel_count = (self.players.count/10.0).round
    
    # this is gross. make it nicer!
    self.players.shuffle.each_with_index do |player, index|
      if index < werewolf_count
        player.assign_role("werewolf")
      elsif index < werewolf_count + seer_count
        player.assign_role("seer")
      elsif index < werewolf_count + seer_count + angel_count
        player.assign_role("angel")
      else
        player.assign_role("villager")
      end
    end
  end
  
  def start
    unless self.started?
      assign_roles
      #@log.add("Game has started.")
      turn = 0
      advance_turn
      log_event "Game #{self.name} started!"
      save
    end
  end
  
  def started?
    self.turn > 0
  end
  
  def is_day?
    (self.turn % 2) == 1
  end

  def is_night?
    if self.turn > 0
      (self.turn % 2) == 0
    else
      return FALSE
    end
  end
  
  def end_turn
    advance_turn
  end
  
  def count_votes
    votes_needed = self.players.living.count / 2 + 1
    #votes_needed = 1
    puts "counting votes..."
    for player in self.players.living
      if player.votes_for.count >= votes_needed
        player.lynch
        end_turn
        return
      end
    end
  end 
  
  def log_event(text)
    EventLog.create(:game_id => self.id, :text => text)
  end
end
