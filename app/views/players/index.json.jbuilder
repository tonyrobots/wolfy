json.array!(@players) do |player|
  json.extract! player, :id, :alias, :role, :alive, :last_move
  json.url player_url(player, format: :json)
end
