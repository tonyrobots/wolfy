# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



User.create(email: "tonyzito@gmail.com", password: "coffee")
puts "created tonyzito@gmail.com user"

10.times do |i|
  User.create(email: "email#{i}@test.com", password: "test")
end

game = Game.create(name: "New Game", creator_id: 1)
puts "created game: New Game"

10.times do |i|
  player_name = Faker::Name.name
  Player.create(alias: player_name, game_id: game.id, user_id: "#{i+1}")
  puts "Created #{player_name} and added to New Game"
end
  