require 'rspec'
require 'leanplum_api'
require 'timecop'
require 'webmock'
require 'webmock/rspec'
require 'vcr'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

DEFAULT_SPEC_KEY = 'JUNKTASTIC_SPASMASTIC'

RSpec.configure do |config|
  config.before(:all) do
    FileUtils.mkdir('log') unless File.exist?('log')

    LeanplumApi.configure do |configuration|
      configuration.production_key = ENV['LEANPLUM_PRODUCTION_KEY'] || DEFAULT_SPEC_KEY
      configuration.app_id = ENV['LEANPLUM_APP_ID'] || DEFAULT_SPEC_KEY
      configuration.data_export_key = ENV['LEANPLUM_DATA_EXPORT_KEY'] || DEFAULT_SPEC_KEY
      configuration.content_read_only_key = ENV['LEANPLUM_CONTENT_READ_ONLY_KEY'] || DEFAULT_SPEC_KEY
      configuration.development_key = ENV['LEANPLUM_DEVELOPMENT_KEY'] || DEFAULT_SPEC_KEY
      configuration.logger.level = Logger::FATAL
    end

    Timecop.freeze('2015-08-12'.to_time.utc)
  end

  config.after(:suite) do
    Dir['log/*.log'].each { |file| File.delete(file) }
    FileUtils.rmdir('log')
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr'
  c.hook_into :webmock
  c.filter_sensitive_data('<LEANPLUM_PRODUCTION_KEY>')        { ENV['LEANPLUM_PRODUCTION_KEY'] || DEFAULT_SPEC_KEY }
  c.filter_sensitive_data('<LEANPLUM_APP_ID>')                { ENV['LEANPLUM_APP_ID'] || DEFAULT_SPEC_KEY }
  c.filter_sensitive_data('<LEANPLUM_CONTENT_READ_ONLY_KEY>') { ENV['LEANPLUM_CONTENT_READ_ONLY_KEY'] || DEFAULT_SPEC_KEY }
  c.filter_sensitive_data('<LEANPLUM_DATA_EXPORT_KEY>')       { ENV['LEANPLUM_DATA_EXPORT_KEY'] || DEFAULT_SPEC_KEY}
  c.filter_sensitive_data('<LEANPLUM_DEVELOPMENT_KEY>')       { ENV['LEANPLUM_DEVELOPMENT_KEY'] || DEFAULT_SPEC_KEY }

  c.default_cassette_options = {
    match_requests_on: [:method, :uri, :body]
  }
end
