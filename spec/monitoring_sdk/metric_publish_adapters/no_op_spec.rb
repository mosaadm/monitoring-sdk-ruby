require 'monitoring_sdk/metric_publish_adapters/no_op'

RSpec.describe MonitoringSDK::MetricPublishAdapters::NoOp do
  subject(:adapter) { described_class.new }

  before do
    adapter.publish({name: 'Elon'})
    adapter.publish({id: 700})
  end

  specify do
    expect(adapter.messages).to eq([{name: 'Elon'}, {id: 700}])
  end
end
