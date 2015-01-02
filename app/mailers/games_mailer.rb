class GamesMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: "wolfmaster@wolfy.herokuapp.com"
  layout 'mailer'
  
  def game_started(player)
    @player = player
    @game = @player.game
    @user = @player.user
    mail(to: @user.email, subject: "Werewolf game \"#{@game.name}\" has begun!") do |format|
      format.html { render layout: 'mailer' }
      format.text
    end
  end
  
  def game_status(player)
    @player = player
    @game = player.game
    @user = player.user
    @remaining_count = @game.players.living.group(:role).count.sort.reverse.sort_by { |x| x[1] }.reverse
    mail(to: @user.email, subject: "Werewolf game \"#{@game.name}\" update") do |format|
      format.html { render layout: 'mailer' }
      format.text
    end
  end
  
  def nudge(player)
    @user = player.user
    @player = player
    @game = player.game
    mail(to: @user.email, subject: "Hey, everyone is waiting for you!")
  end
end
