class Game < ActiveRecord::Base
  has_many :players
  has_many :users, through: :players
  has_one :creator  
  
  def advance_turn
   self.turn += 1
    if is_day?
      #@vote_counter = Vote_counter.new(self.player_list)
      self.state = "day"
      self.save
    elsif is_night?
      self.state = "night"
      for player in @players
        player.last_move = ""
      end
      self.save
    end
    #@log.add "It is now turn #{self.turn} (#{self.state})."
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
        #move this logging to role definition function in player class
        #@log.add "assigned role 'werewolf' to #{player.name}"
        player.assign_role("werewolf")
      elsif index < werewolf_count + seer_count
        #@log.add "assigned role 'seer' to #{player.name}"
        player.assign_role("seer")
      elsif index < werewolf_count + seer_count + angel_count
        #@log.add "assigned role 'angel' to #{player.name}"
        player.assign_role("angel")
      else
        player.assign_role("villager")
        #@log.add "assigned role 'villager' to #{player.name}"
      end
    end
  end
  
  def start
    if self.players.count < 7 
      #TODO Fix this. Maybe need to move to controller?
      puts "too few players."
    end
    self.assign_roles
    #@log.add("Game has started.")
    self.turn = 0
    self.advance_turn
  end
  
  def started?
    self.turn
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
  
end
