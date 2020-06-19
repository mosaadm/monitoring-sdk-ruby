require 'monitoring_sdk/metric_publish_adapters/toptal_water_drop'

RSpec.describe MonitoringSDK::MetricPublishAdapters::ToptalWaterDrop do
  subject(:adapter) { described_class.new }

  specify do
    expect(WaterDrop::AsyncProducer).to receive(:call)
      .with('{"meeting.created.v3":"abc","id":1000}', topic: 'metrics')
    adapter.publish({'meeting.created.v3' => 'abc', id: 1000})
  end
end
