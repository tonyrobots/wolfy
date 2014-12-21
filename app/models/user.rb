class User < ActiveRecord::Base
  has_one :stats, class_name:'UserStats'
  has_many :players
  has_many :games, through: :players
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :username
  validates :username, format: { with: /\A[A-Za-z0-9\-\_\.]+\Z/, message: " can only contain letters, numbers, dots, dashes and underscores." }
  validates :username, length: { in: 3..20 }
  validates :username, uniqueness: { case_sensitive: false }
  
  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login
  
  def to_s
    self.username
  end
  
  def is_playing?(game)
    game.users.include? self
  end
  
  def join(game,player_alias=nil)
    player_alias ||=  Faker::Name.name
    @player = game.players.build(:user => self, :alias => player_alias)
    @player.save
    game.log_and_add_message("Someone has joined the game.")
  end
  
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
end
