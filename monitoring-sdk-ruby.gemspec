# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monitoring_sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'monitoring-sdk-ruby'
  spec.version       = MonitoringSDK::VERSION
  spec.authors       = ['Peter Rezikov']
  spec.email         = ['peter.rezikov@toptal.com']

  spec.summary       = 'SDK for the Toptal Health Monitoring'
  spec.description   = 'SDK for now includes a simple service class for pushing ' \
                       'application health metrics to the Kafka stream.'
  spec.homepage      = 'https://github.com/toptal/monitoring-sdk-ruby'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)

  spec.metadata['allowed_push_host'] = ''

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'oj', '~> 3.0'
  spec.add_dependency 'waterdrop', '~> 1.3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'
end
