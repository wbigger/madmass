module Madmass
  module Comm
          
    class SockySender
      include Singleton
      
      class << self
        def send(percepts, opts)
          # push messages to HTML clients via socky
          Socky.send(percepts.to_json.html_safe, opts)

          # push messages to JMS clients via stomplet
          topic.publish(JSON(percepts), :properties => opts)
          # notify that a perception is sent
          ActiveSupport::Notifications.instrument("madmass.perception_sent")
        end

        private 
        
        def topic
          # FIXME: move destination name in Madmass.config
          @topic ||= TorqueBox::Messaging::Topic.new('/topic/perceptions')
        end

      end
      
    end

  end
end

