# frozen_string_literal: true

require 'monitoring_sdk/metric_publish_adapters/no_op'

RSpec.describe MonitoringSDK::Metrics do
  subject(:metrics) do
    described_class.new(
      domain: domain,
      name: name,
      version: version,
      adapter: adapter,
      application: application,
      schema_version: schema_version,
      delivered_metrics: delivered_metrics
    )
  end

  let(:version) { 1 }
  let(:adapter) { MonitoringSDK::MetricPublishAdapters::NoOp.new }
  let(:domain) { 'billing' }
  let(:name) { 'invoices_sent' }
  let(:application) { 'platform' }
  let(:schema_version) { 2 }
  let(:delivered_metrics) do
    {
      'billing.invoices_sent.v1' => true,
      'active_jobs.perform_start.v1' => false,
      'meetings.new_meeting.v3' => true
    }
  end

  before do
    allow(Socket).to receive(:gethostname).and_return('specs.hostname')

    Timecop.freeze('2020-01-13 12:00:00 UTC')
  end

  describe '#push' do
    let(:expected_message) do
      {
        application: 'platform',
        schemaVersion: 2,
        hostname: 'specs.hostname',
        name: 'billing.invoices_sent.v1',
        tags: {domain: 'billing'},
        timestamp: '2020-01-13T12:00:00Z',
        'billing.invoices_sent.v1' => {baz: 1}
      }
    end

    it 'pushes serialized metrics as message' do
      metrics.push(baz: 1)
      expect(adapter.messages).to eq([expected_message])
    end

    context 'with other parameters' do
      let(:domain) { 'meetings' }
      let(:name) { 'new_meeting' }
      let(:application) { 'top_scheduler' }
      let(:schema_version) { 1 }
      let(:version) { 3 }

      let(:expected_message) do
        {
          application: 'top_scheduler',
          schemaVersion: 1,
          hostname: 'specs.hostname',
          name: 'meetings.new_meeting.v3',
          tags: {domain: 'meetings'},
          timestamp: '2020-01-13T12:00:00Z',
          'meetings.new_meeting.v3' => {guest: 'John'}
        }
      end

      it 'pushes serialized metrics as message' do
        metrics.push(guest: 'John')
        expect(adapter.messages).to eq([expected_message])
      end
    end

    shared_examples 'does not delivers metrics' do
      it 'does not push metrics' do
        metrics.push(baz: 1)
        expect(adapter.messages).to be_empty
      end
    end

    context 'when metrics delivery is disabled via method parameters' do
      let(:delivered_metrics) { {'billing.invoices_sent.v1' => false} }

      include_examples 'does not delivers metrics'
    end

    context 'when metrics delivery is not set for given metrics' do
      let(:delivered_metrics) { {} }

      include_examples 'does not delivers metrics'
    end

    context 'when metrics delivery configuration is not set' do
      let(:delivered_metrics) { nil }

      include_examples 'does not delivers metrics'
    end
  end
end
