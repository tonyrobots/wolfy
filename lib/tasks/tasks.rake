task :email_game_status => :environment do
  desc "send game status email"
  player_id = ENV['player_id'] || 1
  player = Player.find(player_id)
  game = player.game
  puts "Emailing the game state of game #{game.name} to player #{player.alias}..."
  GamesMailer.game_status(player).deliver
end

task :email_game_status_to_all => :environment do
  desc "send game status email"
  game_id = ENV['game_id'] 
  game = Game.find(game_id)
  game.players.each do |player|
    puts "Emailing the game state of game #{game.name} to player #{player.alias}..."
    GamesMailer.game_status(player).deliver
  end
end