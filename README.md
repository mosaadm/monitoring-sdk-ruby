# MonitoringSDK

Toptal Health Monitoring ruby libraries.  

For now this SDK includes only Metrics class and related adapters.
Metrics is a simple mechanism to push gathered metrics to monitoring infrastructure.

## Installation

Add this line to your application's Gemfile:

```ruby

# Most probably this block is already in your Gemfile.
git_source(:toptal) do |repo_name|
  "https://github.com/toptal/#{repo_name}.git"
end

gem 'monitoring-sdk-ruby', toptal: 'monitoring-sdk-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monitoring-sdk-ruby

If you gonna use default WaterDrop adapter for Kafka (`MonitoringSDK::MetricsPublishAdapters::ToptalWaterDrop`),
please properly configure `WaterDrop` gem, e.g.:

`config/initializers/waterdrop.rb`

```ruby
# frozen_string_literal: true

WaterDrop.setup do |config|
  config.deliver = true
  config.client_id = "platform"
  config.kafka.seed_brokers = [Settings.kafka.endpoint]

  config.kafka.ssl_ca_certs_from_system = false
  config.kafka.sasl_over_ssl = false
  config.kafka.sasl_plain_username = Settings.kafka.sasl_plain_username
  config.kafka.sasl_plain_password = Settings.kafka.sasl_plain_password
  config.logger = Rails.logger
end
``` 

## Usage

Just create a new instance of `Metrics` and push your data. 


```ruby
metrics = MonitoringSDK::Metrics.new(
  application: 'platform', 
  chema_version: 1, 
  adapter: MonitoringSDK::MetricsPublishAdapters::ToptalWaterDrop.new,
  domain: 'billing',
  name: 'invoices_sent', 
  version: 1)
  
metrics.push(sent: 5)

```

To avoid repetition of common parameters you can use `Settings` and child class:

```yaml
# config/settings.yml
metrics:
  application: 'platform'
  schema_version: 1
  delivered:
    billing.invoices_sent.v1: false
    enterprise_sales.salesforce_synchronization.v1: false
    platform_top_scheduler.request.v1: false
    platform_action_mailer.mail.v1: true
    engagement_interviews.occurrence_since_1h.v1: true
```

```ruby
# lib/metrics.rb
# frozen_string_literal: true

require "monitoring-sdk-ruby"

module Platform
  class Metrics < MonitoringSDK::Metrics
    def initialize(**params)
      settings = Settings.metrics
      super(application: settings.application,
            schema_version: settings.schema_version, 
            delivered_metrics: settings.delivered,
            adapater: MonitoringSDK::MetricPublishAdapters::ToptalWaterDrop,
            **params)
    end
  end
end
```


Please check [Class Documentation](https://github.com/toptal/metrics/blob/master/lib/metrics.rb) for more information.


## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
