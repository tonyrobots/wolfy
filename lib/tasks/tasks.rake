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

task :nudge => :environment do
  for game in Game.current
    if game.waiting_for.count < 3
      game.waiting_for.each  do |player|
        if player.last_nudged < 6.hours.ago
          puts "Nudging the straggler #{player.user.username} with an email."
          GamesMailer.nudge(player).deliver
          player.update(last_nudged: Time.now)
        end
      end
    end
  end
end
