log_path = File.expand_path("../../log/test.log", __dir__)
ActiveRecord::Base.logger = Logger.new(log_path)
