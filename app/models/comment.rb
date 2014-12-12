class Comment < ActiveRecord::Base
  belongs_to :player
  belongs_to :game
  validates :body, presence: true, length: {maximum: 2000}
end
