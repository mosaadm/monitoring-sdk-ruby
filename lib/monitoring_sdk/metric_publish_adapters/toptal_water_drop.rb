require 'oj'
require 'waterdrop'

module MonitoringSDK
  module MetricPublishAdapters
    # Main default adapter for Kafka. It publishes messages to Toptal's Kafka metrics topic
    # through WaterDrop library.
    class ToptalWaterDrop
      # Kafka topic that we use for metrics messages in Toptal
      KAFKA_TOPIC = 'metrics'.freeze

      # @param message [Hash] metrics message
      def publish(message)
        WaterDrop::AsyncProducer.call(
          Oj.dump(message, mode: :compat),
          topic: KAFKA_TOPIC
        )
      end
    end
  end
end
