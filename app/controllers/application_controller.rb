class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def current_player(game)
    if current_user
      game.players.where(user_id:current_user.id).last
    end
  end
  helper_method :current_player
  
  def add_message(game, msg)
    @comment = game.comments.build(game_id:game.id, body:msg)
    @comment.save
  end
  
end
