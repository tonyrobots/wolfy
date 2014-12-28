class GamesController < ApplicationController
  before_action :set_game, except: [:index, :new, :create]
  before_filter :authenticate_user!, except: [:index]
  before_filter :players_only, only:[:show]
  
  def join
    # probably move some of this logic to model?
    if @game.turn > 0
      logger.error "Attempt to join started game #{@game.id}"
      redirect_to game_url, :alert => "Too late to join that game!"
    elsif !current_user
      logger.error "Attempt by non-logged in user to join game #{@game.id}"
      redirect_to game_url, :alert => "You need to be logged in to join."
    elsif @game.users.include?(current_user)
      # TODO this seems to be firing when users try to join games -- they join successfully, but this condition is met. Look into it.
      logger.error "User #{current_user.id} tried to join game #{@game.id} twice."
      redirect_to game_url
    else
      if params[:alias].present?
        player_alias = params[:alias].strip
      end
      current_user.join(@game,player_alias)
      @game.reload_clients
      respond_to do |format|
        if @player.save
          format.html { redirect_to @game }
          format.json { render action: 'show', status: :created, location: @game }
        else
          format.html { render action: 'new' }
          format.json { render json: @game.errors, status: :unprocessable_entity }
        end
      end
    end
  end
  
  def start
    # TODO message to user why the game can't start?
    if @game.ready_to_start?
      @game.start
      flash[:success] = "The game has begun!"
    end
    redirect_to @game
  end

  # GET /games
  # GET /games.json
  def index
    if current_user
      @recently_finished = current_user.games.where(state:"finished").where("games.updated_at > ?", 4.weeks.ago).order("games.updated_at DESC").limit(5)
      @user_games = current_user.current_games
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    player = current_player(@game)
    @votee = player.voted_for
    @comment = Comment.new
    @comments = player.readable_comments
    if player.can_pm_to
      @comment_targets = [["Everyone", nil]] + player.can_pm_to
    end
    # all this sorting is to make sure there is no information passed by the order of roles presented in list:
    @remaining_count = @game.players.living.group(:role).count.sort.reverse.sort_by { |x| x[1] }.reverse
    gon.channel = "/channel-#{@game.id}"
    gon.private_channel = "/channel-p-#{current_player(@game).id}"
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end
  
  def vote
    if @game.started? and @game.is_day?
      @votee = Player.find(params[:votee_id])
      voter = current_player(@game)
      if voter.voted_for and (voter.voted_for != @votee)
        msg = "#{voter.alias} changed vote from #{voter.voted_for.alias} to #{@votee.alias}."
      else
        msg = "#{voter.alias} voted for #{@votee.alias}."
      end
      voter.vote_for(@votee)
      @game.log_and_add_message(msg)
      @game.count_votes
      @game.reload_clients
    else
      flash.alert = "You can't vote now!"
    end
    respond_to do |format|
      #format.html { redirect_to @game }
      format.js
    end
  end

  def move
    move = params[:move]
    target = Player.find_by_id(params[:target])
    case move
    when "attack"
      current_player(@game).attack(target)
      msg = "#{current_player(@game).alias} will attack #{target.alias} tonight."
      @game.broadcast_to_role("werewolf", msg)
      @game.log_event msg
    when "reveal"
      current_player(@game).reveal(target)
      msg = "#{current_player(@game).alias} will reveal #{target.alias} tonight."
      @game.log_event msg
    when "protect"
      current_player(@game).protect(target)
      msg = "#{current_player(@game).alias} will protect #{target.alias} tonight."
      @game.log_event msg
    end
    #flash[:success] = "You made your #{move} move on #{target.alias}."
    @game.check_if_night_is_over
    redirect_to @game
  end
    
    
    
  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)
    @game.creator_id = current_user.id
    
    respond_to do |format|
      if @game.save
        current_user.join(@game)
        format.html { redirect_to @game }
        format.json { render action: 'show', status: :created, location: @game }
      else
        format.html { render action: 'new' }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    if @game.creator == current_user
      respond_to do |format|
        if @game.update(game_params)
          format.html { redirect_to @game }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @game.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end
        
    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:name, :turn, :state, :description)
    end
    
    def players_only
      set_game
      unless current_user.is_playing?(@game)
        flash[:warning] = "You must be a player in a game to view it."
        redirect_to games_path
      end
    end
end
