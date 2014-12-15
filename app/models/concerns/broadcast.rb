module Broadcast
  extend ActiveSupport::Concern
  include Messaging

  def broadcast(channel, payload)
    begin
      Messaging.bayeux.publish(channel, payload )
    rescue => e
      puts "can't broadcast message #{payload}"
      logger.error e.message
      #logger.error e.backtrace.join("\n")
    end
  end
end