class Game < ActiveRecord::Base
  include Broadcast

  has_many :players, dependent: :destroy
  has_many :users, through: :players
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  has_many :event_logs, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :moves, dependent: :destroy

  scope :current, -> { where("turn > 0").where.not(state:"finished") }

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
    log_and_add_message msg
    send_status
    reload_clients
  end

  def assign_roles
    # Should confirm correct conditions (e.g. turn ==0)?
    # update these counts later so they are based on @rules hash
    # make role an object?
    # werewolf_count = (self.players.count/self.rules[:wolf_ratio]).round
    # seer_count = (self.players.count/self.rules[:seer_ratio]).round
    # angel_count = (self.players.count/self.rules[:angel_ratio]).round
    werewolf_count = (players.count/4.6).round
    seer_count = (players.count/11.0).round
    angel_count = (players.count/13.0).round

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

  def min_players
    # later this will be based on game options, roles, etc.
    6
  end

  def ready_to_start?
    self.players.count >= self.min_players and not self.started?
  end

  def is_day?
    turn > 0 && ((turn % 2 == 0) == self.nightstart)
  end

  def is_night?
    turn > 0 && ((turn % 2) == 0) != self.nightstart
  end

  def is_over?
    self.state == "finished"
  end

  def end_turn
    # check if victory conditions have been met
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
    self.update(state:"finished", winner:winners)
    good_guys_won = winners != "werewolves"
    for player in self.players
      player.record_stats(good_guys_won == player.good_guy?,player.alive)
    end
    log_and_add_message msg
    reload_clients
    send_status
  end

  def count_votes
    #TODO: Refactor so all players/majority and 'more than half' voting is counted in one pass
    votes_needed = self.players.living.count / 2 + 1
    # if all players have voted, and one player (alone) has most votes, they are off

    if votes.for_turn(self.turn).count == players.living.count #everyone has voted
      votes_counts = self.votes.for_turn(self.turn).group(:votee_id).count
      max = votes_counts.values.max
      top_vote_getters = Hash[votes_counts.select { |k, v| v == max}]
      if top_vote_getters.count == 1
        Player.find(top_vote_getters.first[0]).lynch
        end_turn
        return
      else
        deadlocked_players = []
        top_vote_getters.each do |id, count|
          deadlocked_players << Player.find(id).alias
        end
        self.add_message("Voting is deadlocked between #{deadlocked_players.to_sentence}.")
      end
    end

    # otherwise, if one player has more than half of the group voting against them, they are out
    for player in self.players.living
      votes_against = player.votes_for.for_turn(self.turn).count
      if votes_against >= votes_needed
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
      if attack_target.role != "werewolf"
        msg = "You awaken to a blood-curdling scream! #{attack_target.alias} was killed by werewolves."
      else
        msg = "Oh my! In a bizarre twist, you awaken to find that #{attack_target.alias} was murdered by werewolves!"
      end
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

  def waiting_for
    waiting_list = []
    if is_day?
      for player in self.players.living
        next if player.voted_for
        waiting_list << player
      end
    elsif is_night?
      for player in self.players.living.non_villagers
        next if player.current_move
        waiting_list << player
      end
    end
    waiting_list
  end

  def log_and_add_message(msg)
    log_event msg
    add_message msg
  end

  def log_event(text)
    EventLog.create(:game_id => self.id, :text => text, turn: self.turn)
  end

  def add_message(msg, player=false)
    @comment = self.comments.build(game_id:self.id, body:msg)
    @comment.save
    if player
      channel = player.channel
    else
      channel = self.channel
    end
    payload = { message: ApplicationController.new.render_to_string(@comment)}
    self.broadcast(channel, payload)
  end

  def broadcast_to_role(role, msg, sender=false)
    for player in self.players.living
      if player.role == role
        player.private_message(msg, sender)
      end
    end
  end

  def broadcast_comment_to_role(comment, role)
    for player in self.players.living.where(role: role)
      player.private_send(comment)
    end
  end

  def reload_clients
    broadcast "/channel-#{self.id}", {reload: true}
  end

  def send_status
    players.each do |player|
      GamesMailer.game_status(player).deliver
    end
  end

end
