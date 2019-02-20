source "http://rubygems.org"

gemspec

group :development do
  gem "database_cleaner"
  gem "fabrication"
  gem "activesupport"
  gem "forgery"
  gem "pry"
  gem "rake"
  gem "rspec", "~> 3.5"
  gem "rspec-its"
  gem "solid_assert", "~> 1.0"

  if RUBY_ENGINE == "jruby"
    gem "activerecord-jdbcmysql-adapter"
    gem "activerecord-jdbcpostgresql-adapter"
    gem "activerecord-jdbcsqlite3-adapter"
  else
    gem "mysql2"
    gem "pg"
    gem "sqlite3", "~> 1.3.6"
  end
end

gem "codecov", require: false, group: :test
gem "simplecov", require: false, group: :test
