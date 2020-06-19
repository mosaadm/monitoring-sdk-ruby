# frozen_string_literal: true

module MonitoringSDK
  # Implements a simple mechanism to push gathered metrics to monitoring infrastructure.
  # Each metric consists of the name, tags and its data. There are few conventions
  # and limitations to take into account.
  #
  # Final stored metric name is constructed by domain, name and version:
  #
  # | domain           | name                       | version | stored name                                    |
  # |------------------|----------------------------|---------|------------------------------------------------|
  # | billing          | invoices_sent              | 1       | billing.invoices_sent.v1                       |
  # | billing          | invoices_sent              | 2       | billing.invoices_sent.v2                       |
  # | billing          | pending_charge_time        | 1       | billing.pending_charge_time.v1                 |
  # | enterprise_sales | salesforce_synchronization | 1       | enterprise_sales.salesforce_synchronization.v1 |
  #
  # Additionally, metric domain will be stored in `tags` object.
  #
  # Metric data should maintain its types. Since pushed metrics are stored in
  # Elasticsearch indices, it will automatically map index types on the first push.
  # After that, it will reject any data that cannot be mapped to the type mapping.
  # For example,
  #
  #   metric = MonitoringSDK::Metrics.new(
  #     domain: 'billing', name: 'invoices_sent', version: 1,
  #     adapter: MonitoringSDK::MetricsPublishAdapters::ToptalWaterDrop.new
  #   )
  #   metric.push(sent: 50) # this creates index mapping `sent: long`.
  #   metric.push(sent: 10) # this works fine
  #   metric.push(sent: {}) # this won't work!
  #
  # If you want to change existing metric types, simply create a new version of
  # same metric and push new data to it.
  #
  # @example
  #   MonitoringSDK::Metrics
  #     .new(domain: 'billing', name: 'invoices_sent', version: 2,
  #          application: 'platform', schema_version: 1,
  #          adapter: MonitoringSDK::MetricsPublishAdapters::ToptalWaterDrop)
  #     .push(sent: 5)
  #
  # You can avoid repetition of `application`, `schema_version` and `adapter` parameters with own child class.
  #
  class Metrics
    # @param domain [String] domain of a metric, e.g. 'billing', 'enterprise_sales'.
    # @param name [String] name of a metric, e.g. 'pending_charge_time'.
    # @param version [Integer] version of a metric, e.g. 1.
    #   Version could be changed for example when you change a type of a metric's value.
    # @param application [String] name of the application e.g. "platform".
    #    By default it should be set on the initialization.
    # @param schema_version [String] version of the metrics schema. e.g. 1.
    #    By default it should be set on the initialization.
    # @param adapter [#publish] Instance of adapter class
    #   (e.g. `MonitoringSDK::MetricsPublishAdapters::ToptalWaterDrop`) with publish method receiving message hash.
    # @param delivered_metrics [Hash|Config::Options] - configuration for metric that should be delivered in the
    #   current environment. For many reasons we need to disable/enable some metrics only in concrete environments.
    #
    #   For example configure your metrics with a settings.yml:
    #
    #   ```yml
    #   metrics:
    #     deliver:
    #       billing.invoices_sent.v1: false
    #       platform_action_mailer.mail.v1: true
    #   ```
    #
    #   And then pass it to the initializer
    #   ```ruby
    #   Metrics.new(..., delivered_metrics: Settings.metrics.delivered)
    #   ```
    #
    #   *WARNING* you should set this setting for each metric you want to use.
    #   If you do not set any value for some metric it will be considered as false.
    #
    # rubocop:disable Metrics/ParameterLists most of these params could be eliminated by setting in
    #   a parent class for each project.
    def initialize(domain:, name:, version:, application:, adapter:, schema_version:, delivered_metrics:)
      @name = "#{domain}.#{name}.v#{version}"
      @tags = {domain: domain}
      @adapter = adapter
      @application = application
      @schema_version = schema_version
      @default_properties = default_properties
      @delivered_metrics = delivered_metrics || {}
    end
    # rubocop:enable Metrics/ParameterLists

    # Pushes data to monitoring.
    # @param data [Hash] JSON-serializable hash.
    def push(**data)
      return unless deliver?(@name)

      @adapter.publish(@default_properties.merge(@name => data))
    end

    private

    def deliver?(name)
      @delivered_metrics[name]
    end

    def default_properties
      {
        application: @application,
        schemaVersion: @schema_version,
        hostname: Socket.gethostname,
        name: @name,
        tags: @tags,
        timestamp: Time.now.utc.iso8601
      }
    end
  end
end
