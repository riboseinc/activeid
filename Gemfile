source "http://rubygems.org"

gemspec

group :development do
  gem "activesupport"
  gem "pry"
  gem "rake"

  platform :jruby do
    gem "activerecord-jdbcmysql-adapter"
    gem "activerecord-jdbcpostgresql-adapter"
    gem "activerecord-jdbcsqlite3-adapter"
  end

  platform :ruby do
    gem "mysql2"
    gem "pg"
    gem "sqlite3", "~> 1.3.6"
  end
end

group :examples do
  gem "solid_assert", "~> 1.0"
end

group :test do
  gem "codecov", require: false
  gem "database_cleaner"
  gem "fabrication"
  gem "forgery"
  gem "rspec", "~> 3.5"
  gem "rspec-its"
  gem "simplecov", require: false
end
