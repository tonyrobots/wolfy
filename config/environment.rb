# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Werewolf::Application.initialize!

MOVES ={
  "werewolf" => "attack",
  "seer" => "reveal",
  "angel" => "protect"
}
