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
  
  def add_message(game, msg, player = false)
    @comment = game.comments.build(game_id:game.id, body:msg)
    puts "GARGAMEL"
    @comment.save
    if player
      channel = "channel-p-#{player.id}"
    else
      channel = "/channel-#{game.id}"
    end
    message = "#{msg}<br/>"
    payload = { message: render_to_string(@comment)}
    broadcast(channel, payload)
  end
  
  def broadcast(channel, payload)
    # if you have problems don't forget about event machine start
    client = Faye::Client.new("#{request.base_url}/faye")
    client.publish(channel, payload )
  end
  
  def commentify_system_message(game, msg)
    comment = Comment.new
  end
  
end
