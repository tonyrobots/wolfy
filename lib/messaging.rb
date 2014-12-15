module Messaging
  def self.bayeux
    @bayeux_client ||= Faye::Client.new("#{BASE_URL}/faye")
  end
end