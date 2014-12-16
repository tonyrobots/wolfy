namespace :debug do
  task :night_moves => :environment do
    desc "random night moves to help move things along"
    game_id = ENV['game_id'] || 1
    puts "Random night moves for game #{game_id}..."
    game = Game.find(game_id)
    for player in game.players.living.non_villagers
      next if player.current_move
      if player.role == "seer"
        player.reveal(game.players.living.shuffle.first)
      elsif player.role == "angel"
        player.protect(game.players.living.shuffle.first)
      elsif player.role == "werewolf"
        if wolfmove = game.moves.where(turn:game.turn).where(action:"attack").first
          player.attack(wolfmove.target)
        else
          player.attack(game.players.living.shuffle.first)
        end
      end
    end
    game.check_if_night_is_over
  end
  
  task :vote => :environment do
    desc "random votes to help move things along"
    game_id = ENV['game_id'] || 1
    puts "Random votes for game #{game_id}..."
    game = Game.find(game_id)
    votee = game.players.living.shuffle.last
    for player in game.players.living
      next if player.voted_for
      player.vote_for(votee)
      puts "#{player.alias} voted for #{votee.alias}"
    end
    game.count_votes
  end
  
  task :add_players => :environment do
    desc "fill game with random players"
    game_id = ENV['game_id'] || 1
    puts "Filling game #{game_id} with random players..."
    game = Game.find(game_id)
    8.times do |i|
      player_name = Faker::Name.name
      Player.create(alias: player_name, game_id: game.id, user_id: "#{i+3}")
      puts "Created #{player_name} and added to #{game.name}"
    end
  end
end
