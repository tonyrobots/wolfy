class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def current_player(game)
    game.players.where(user_id:current_user.id).last
  end
  helper_method :current_player
  
end
