module MonitoringSDK
  module MetricPublishAdapters
    # This adapter just collect published messages in the memory.
    # You can use it for unit tests and other kind of testing.
    class NoOp
      attr_reader :messages

      def initialize
        @messages = []
      end

      # @param message [Hash] metric message
      def publish(message)
        @messages << message
      end
    end
  end
end
