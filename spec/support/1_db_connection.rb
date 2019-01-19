db_config_path = File.expand_path("database.yml", __dir__)
ActiveRecord::Base.configurations = YAML::safe_load(File.read(db_config_path))
ActiveRecord::Base.establish_connection(ENV["DB"].to_sym)
