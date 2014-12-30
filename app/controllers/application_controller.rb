class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_open_games
  
  
  def current_player(game)
    if current_user
      game.players.where(user_id:current_user.id).first
    end
  end
  helper_method :current_player
  
  def set_open_games
    @open_games = Game.where(turn:0)
    if current_user
      @open_games = @open_games.where.not(:id => current_user.players.select(:game_id).uniq)
    end
  end
  
  protected
  def validate_admin_user
    unless user_signed_in? and current_user.is_admin?
      redirect_to root_path
    end
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
  
end
