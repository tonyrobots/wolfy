class Comment < ActiveRecord::Base
  belongs_to :player
  belongs_to :game
  belongs_to :target, :class_name => 'Player', :foreign_key => 'target_id'
  validates :body, presence: true, length: {maximum: 2000}
  
  scope :public, -> { where(target_id:nil).where(target_role:nil) }
  
 
  def self.parse_comment(comment)
    if msg = comment.match(/^(\/\w)\s+(\w+)(.*)/i)
      if msg[1] == "/w"
        return {type: :role, target:"werewolf", body: (msg[2] + msg[3]).strip}
      else
        return {type: :private, target: msg[2], body: msg[3]}
      end
    else 
      return {type: :normal, target: "none", body: comment}
    end
  end
  
end
