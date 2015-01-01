class GamesMailer < ActionMailer::Base
  default from: "wolfmaster@wolfy.herokuapp.com"
  
  def game_started(game)
    @game = game
    for @player in game.players
      @user = @player.user
      # send
      mail(to: @user.email, subject: "Werewolf game \"#{@game.name}\" has begun!")
    end
  end
end
