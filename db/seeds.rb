# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



User.create(email: "tonyzito@gmail.com", password: "coffee")

10.times do |i|
  User.create(email: "email#{i}@test.com", password: "test")
end

game = Game.create(name: "New Game", creator_id: 1)

10.times do |i|
  Player.create(alias: Faker::Name.name, game_id: game.id, user_id: "#{i+1}")
end
  