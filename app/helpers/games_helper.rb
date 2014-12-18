module GamesHelper
  def current_user_is_creator
    current_user and current_user == @game.creator
  end
end
