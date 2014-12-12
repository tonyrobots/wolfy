class Comment < ActiveRecord::Base
  belongs_to :player
  validates :body, presence: true, length: {maximum: 2000}
end
