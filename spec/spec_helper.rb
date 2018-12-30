require "simplecov"
SimpleCov.start

if ENV.key?("CI")
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

ENV["DB"] ||= "sqlite3"

require "rubygems"
require "bundler/setup"

Bundler.require :development

require "active_record"
require "active_support/all"

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.configurations = YAML::safe_load(File.read(File.dirname(__FILE__) + "/support/database.yml"))

require "activeuuid"

ActiveRecord::Base.establish_connection(ENV["DB"].to_sym)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

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
