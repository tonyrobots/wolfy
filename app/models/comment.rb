class Comment < ActiveRecord::Base
  belongs_to :player
  belongs_to :game
  belongs_to :target, :class_name => 'Player', :foreign_key => 'target_id'
  validates :body, presence: true, length: {maximum: 2000}
  
  scope :public, -> { where(target_id:nil) }
  
end
