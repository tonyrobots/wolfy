class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy, :start, :vote]
  
  def join
    set_game
    if @game.turn
      logger.error "Attempt to join started game #{@game.id}"
      redirect_to game_url, :alert => "Too late to join that game!"
    elsif !current_user
      logger.error "Attempt by non-logged in user to join game #{@game.id}"
      redirect_to game_url, :alert => "You need to be logged in to join."
    elsif @game.users.include?(current_user)
      logger.error "User #{current_user.id} tried to join game #{@game.id} twice."
      redirect_to game_url, :alert => "You are already in that game!"
    else
      @player = @game.players.build(:user => current_user)
      respond_to do |format|
        if @player.save
          format.html { redirect_to @game, notice: 'Player was successfully created.' }
          format.json { render action: 'show', status: :created, location: @game }
        else
          format.html { render action: 'new' }
          format.json { render json: @game.errors, status: :unprocessable_entity }
        end
      end
    end
  end
  
  def start
    @game.start
    render "games/show"
  end

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @votee = current_player(@game).voted_for
    @comment = Comment.new
    @comments = Comment.where(game_id:@game.id).order('created_at ASC')
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end
  
  def vote
    votee = Player.find(params[:votee_id])
    current_player(@game).vote_for(votee)
    redirect_to @game
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)
    @game.creator_id = current_user.id

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
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
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @game.errors, status: :unprocessable_entity }
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
      params.require(:game).permit(:name, :turn, :state)
    end
end
