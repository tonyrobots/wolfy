namespace :debug do
  task :night_moves => :environment do
    desc "random night moves to help move things along"
    game_id = ENV['game_id'] || 1
    puts "Random night moves for game #{game_id}..."
    game = Game.find(game_id)
    for player in game.players.living.non_villagers
      next if player.current_move
      if player.role == "seer"
        player.reveal(game.players.living.where.not(id:player.id).shuffle.first)
      elsif player.role == "angel"
        player.protect(game.players.living.where.not(id:player.id).shuffle.first)
      elsif player.role == "werewolf"
        if wolfmove = game.moves.where(turn:game.turn).where(action:"attack").first
          player.attack(wolfmove.target)
        else
          player.attack(game.players.living.where.not(role:"werewolf").shuffle.first)
        end
      end
    end
    game.check_if_night_is_over
  end
  
  task :vote => :environment do
    desc "random votes to help move things along"
    force = ENV['force']
    game_id = ENV['game_id'] || 1
    puts "Random votes for game #{game_id}..."
    game = Game.find(game_id)
    for player in game.players.living
      votee = game.players.living.where.not(id:player.id).shuffle.last
      next if player.voted_for and not force
      player.vote_for(votee)
      puts "#{player.alias} voted for #{votee.alias}"
    end
    game.count_votes
  end
  
  task :add_players => :environment do
    desc "fill game with random players"
    game_id = ENV['game_id'] || 1
    number = ENV['num'].to_i || 7 #this doesn't work because nil.to_i == 0
    puts "Filling game #{game_id} with #{number} random players..."
    game = Game.find(game_id)
    number.times do |i|
      player_name = Faker::Name.name
      Player.create(alias: player_name, game_id: game.id, user_id: "#{i+3}")
      puts "Created #{player_name} and added to #{game.name}"
    end
  end
  
  task :advance => :environment do
    game = Game.last
    ENV['game_id'] = game.id.to_s
    if game.is_day?
      Rake::Task["debug:vote"].invoke
    elsif game.is_night?
      Rake::Task["debug:night_moves"].invoke
    elsif not game.started?
      ENV['num'] = "7"
      Rake::Task["debug:add_players"].invoke
    end
  end
end
