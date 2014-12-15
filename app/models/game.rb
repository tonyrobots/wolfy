class Game < ActiveRecord::Base
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  has_many :event_logs, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :moves, dependent: :destroy
  
  def channel
    "/channel-#{self.id}"
  end
  
  def role_count
    # probably can DRY this
    {
      werewolf: players.living.where(role:"werewolf").count,
      seer: players.living.where(role:"seer").count,
      angel: players.living.where(role:"angel").count,
      villager: players.living.where(role:"villager").count
    }
  end
  
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
    msg =  "It is now turn #{self.turn} (#{self.state})."
    log_event msg
    add_message msg
    reload_clients
  end
  
  def assign_roles
    #probably make this protected somehow so only self can run, also should confirm correct conditions (e.g. turn ==0)
    #update these counts later so they are based on @rules hash
    #make role an object?
    # werewolf_count = (self.players.count/self.rules[:wolf_ratio]).round
    # seer_count = (self.players.count/self.rules[:seer_ratio]).round
    # angel_count = (self.players.count/self.rules[:angel_ratio]).round
    werewolf_count = (players.count/5.0).round
    seer_count = (players.count/10.0).round
    angel_count = (players.count/10.0).round
    
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
      msg = "Game \"#{self.name}\" has begun."
      log_event msg
      add_message msg
      assign_roles
      set_initial_knowledge
      advance_turn
    end
  end
  
  def started?
    turn > 0
  end
  
  def is_day?
    turn > 0 && (turn % 2) == 1
  end

  def is_night?
    if self.turn > 0
      (self.turn % 2) == 0
    else
      return FALSE
    end
  end
  
  def end_turn
    #first, check if victory conditions have been met
    werewolf_count = self.role_count[:werewolf]
    if werewolf_count == 0
      # villagers win!
      self.game_over("villagers")
      return
    elsif werewolf_count * 2 >= self.players.living.count
      # werewolves win!
      self.game_over("werewolves")
      return
    end
    self.advance_turn
  end
  
  def game_over(winners)
    msg = "The game is over! The #{winners} have won!"
    self.update(turn:-1)
    # add field to game with winner info, update that
    log_and_add_message msg
    reload_clients
  end
  
  def count_votes
    #votes_needed = self.players.living.count / 2 + 1
    votes_needed = 2
    puts "counting votes..."
    # if player has majority of votes, he's out
    most_votes = 0
    #TODO if all players have voted, and one player (alone) has most votes, they are off
    for player in self.players.living
      if player.votes_for.where(turn:self.turn).count >= votes_needed
        player.lynch
        end_turn
        return
      end
    end
  end 
  
  def check_if_night_is_over
    for player in self.players.living.non_villagers
      if self.moves.where(turn:self.turn).where(player:player).first
        puts "#{player.alias} has moved."
      else
        return
        break
      end
    end
    #make sure werewolves agree
    prospective_target = self.players.living.where(role:"werewolf").first.current_move.target
    for wolf in self.players.living.where(role:"werewolf")
      if wolf.current_move.target != prospective_target
        puts "Werewolves don't agree!"
        return
        break
      end
    end
    msg = "Night is over."
    log_and_add_message msg
    evaluate_night_moves(prospective_target)
    self.end_turn
  end
  
  def evaluate_night_moves(attack_target)
    # kills first
    if self.moves.where(turn:self.turn).where(action:"protect").pluck(:target_id).include? attack_target.id
      # victim was protected!
      msg = "You awaken to an eerie quiet. Nobody was killed last night!"
      log_and_add_message msg
    else
      # uh oh...
      msg = "You awaken to a blood-curdling scream! #{attack_target.alias} was killed by werewolves."
      log_and_add_message msg
      attack_target.kill
    end
    #reveal seer info
    for move in self.moves.where(turn:self.turn).where(action:"reveal")
      next unless move.player.alive
      move.player.knows_about!(move.target)
      msg = "#{move.player.alias} revealed #{move.target.alias} as a #{move.target.role}."
      log_event msg
      move.player.private_message("You have seen that #{move.target.alias} is a #{move.target.role}.")
    end
  end
  
  def set_initial_knowledge
    for player in self.players
      case player.role
      when "werewolf"
        for wolf in self.players.werewolves
          player.knows_about!(wolf)
          puts "#{player.alias} knows about #{wolf.alias}"
        end
      end
    end
  end
  
  def log_and_add_message(msg)
    log_event msg
    add_message msg
  end
  
  def log_event(text)
    EventLog.create(:game_id => self.id, :text => text)
  end
  
  def add_message(msg, player=false)
    @comment = self.comments.build(game_id:self.id, body:msg)
    @comment.save
    if player
      channel = "channel-p-#{player.id}"
    else
      channel = self.channel
    end
    payload = { message: ApplicationController.new.render_to_string(@comment)}
    self.broadcast(channel, payload)
  end
  
  def broadcast(channel, payload)
    # if you have problems look into event machine start
    # TODO find way to request.base_url (or equiv) here 
    base_url = "http://localhost:7777"
    client = Faye::Client.new("#{base_url}/faye")
    client.publish(channel, payload )
    #bayeux.get_client.publish(channel, payload )
  end
  
  def broadcast_to_role(role, msg, sender=false)
    for player in self.players.living
      if player.role == role
        player.private_message(msg, sender)
      end
    end
  end
  
  def reload_clients
    broadcast "/channel-#{self.id}", {reload: true}
  end
    
end
