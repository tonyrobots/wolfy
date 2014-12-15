class Vote < ActiveRecord::Base
  belongs_to :voter, :class_name => 'Player', :foreign_key => 'voter_id'
  belongs_to :votee, :class_name => 'Player', :foreign_key => 'votee_id'
end
