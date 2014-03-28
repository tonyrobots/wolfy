json.array!(@games) do |game|
  json.extract! game, :id, :name, :turn, :state
  json.url game_url(game, format: :json)
end
