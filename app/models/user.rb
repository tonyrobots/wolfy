class User < ActiveRecord::Base
  
  has_many :players
  has_many :games, through: :players
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  def is_playing?(game)
    game.users.include? self
  end
  
  def join(game)
    game.users << self
  end
  
end
