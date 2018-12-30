require "simplecov"
SimpleCov.start

if ENV.key?("CI")
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

ENV["DB"] ||= "sqlite3"

require "bundler/setup"
Bundler.require :development

require "activeuuid"

ActiveRecord::Base.logger = Logger.new(File.expand_path("debug.log", __dir__))
ActiveRecord::Base.configurations = YAML::safe_load(File.read(File.expand_path("support/database.yml", __dir__)))
ActiveRecord::Base.establish_connection(ENV["DB"].to_sym)

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require "rspec/expectations"
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
