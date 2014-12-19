class Player < ActiveRecord::Base
  
  include Broadcast
  
  belongs_to :user
  belongs_to :game
  has_many :votes, foreign_key: :voter_id
  has_many :moves
  has_many :votes_for, class_name: 'Vote', foreign_key: :votee_id
  has_many :comments, dependent: :delete_all
  has_many :comments_to, class_name: 'Comment', foreign_key: :target_id
  
  scope :living, -> { where(alive: true) }
  scope :dead, -> { where(alive: false) }
  scope :non_villagers, -> { where.not(role:"villager") }
  scope :werewolves, -> {where(role:"werewolf")}
  
  validates :alias, uniqueness: { scope: :game_id,
      message: "That alias is already being used in this game." }
  
  def to_s
    self.alias
  end
  
  def channel
    "/channel-p-#{self.id}"
  end
  
  def readable_comments
    @comments = self.game.comments.public + self.comments_to + self.comments.where.not(target_id:nil)
    @comments.uniq.sort_by(&:created_at).reverse
    #@comments = self.game.comments.public.merge(self.comments_to)
  end
  
  def assign_role(role)
    self.role = role
    self.alive = true
    self.game.log_event "#{self.alias} is a #{self.role}."
    self.private_message "You are a #{self.role}."
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
    end
  end
  
  def clear_vote!
    self.votes.where(turn:self.game.turn).destroy_all
  end
  
  def clear_move!
    self.moves.where(turn:self.game.turn).destroy_all
  end
  
  def voted_for
    begin
      Player.find(self.votes.where(turn:self.game.turn).last.votee_id)
    rescue
      nil
    end
  end
  
  def good_guy?
    role != "werewolf"
  end
  
  ### Player actions
    
  def attack(target)
    if self.game_id == target.game_id
      if self.role == "werewolf"
        self.clear_move!
        @move = self.moves.build(target:target,game_id:self.game.id,turn:self.game.turn,action:"attack")
        @move.save
      end
    end
  end
  
  def reveal(target)
    if self.game_id == target.game_id
      if self.role == "seer"
        self.clear_move!
        @move = self.moves.build(target:target,game_id:self.game.id,turn:self.game.turn,action:"reveal")
        @move.save
      end
    end
  end

  def protect(target)
    if self.game_id == target.game_id
      if self.role == "angel"
        self.clear_move!
        @move = self.moves.build(target:target,game_id:self.game.id,turn:self.game.turn,action:"protect")
        @move.save
      end
    end
  end
  
  def current_move
    self.moves.where(turn:self.game.turn).last
  end
  
  def private_message(msg,sender=false)
    if sender
      @comment = Comment.new(game_id:self.game_id, body:msg, created_at:Time.now, player_id:sender.id, target_id:self.id)
    else
      @comment = Comment.new(game_id:self.game_id, body:msg, created_at:Time.now, target_id:self.id)
    end
    @comment.save
    private_send(@comment)
  end
  
  def private_send(comment)
    payload = { message: ApplicationController.new.render_to_string(comment)}
    self.broadcast(self.channel, payload)
  end
  
  def knows_about?(target)
    self.knowledge.include? target.id
  end
  
  def knows_about!(target)
    self.knowledge << target.id
    self.knowledge_will_change!
    self.save!
  end
  
  def record_stats(player_won, player_survived)
    @stats = self.user.stats || UserStats.new(user_id: self.user.id)
    @stats.played_count += 1
    @stats.wins_count +=1 if player_won
    @stats.survived_count +=1 if player_survived

    case self.role
    when "werewolf"
      @stats.wolf_count +=1
    when "seer"
      @stats.seer_count +=1
    when "angel"
      @stats.angel_count +=1
    when "illusionist"
      @stats.illusionist_count +=1
    when "villager"
      @stats.villager_count +=1
    end
    @stats.save
  end
end
