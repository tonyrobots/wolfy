class EventLogsController < ApplicationController
  def index
    set_game
    if @game.state == "finished"
      @logs = @game.event_logs.order("created_at ASC")
    else
      flash[:danger] = "You can't view game logs until the game is over, cheater!"
      redirect_to @game
    end
  end
    
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:game_id])
    end

end