class EventLogsController < ApplicationController
  def index
    set_game
    @logs = @game.event_logs
  end
    
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:game_id])
    end

end