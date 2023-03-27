# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "activeid/version"

Gem::Specification.new do |s|
  s.name        = "activeid"
  s.version     = ActiveID::VERSION
  s.authors       = ["Ribose Inc."]
  s.email         = ["open.source@ribose.com"]
  s.homepage    = "https://github.com/riboseinc/activeid"
  s.summary     = "Support for binary UUIDs in ActiveRecord"
  s.description = "Support for binary UUIDs in ActiveRecord"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "activesupport"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "fabrication"
  s.add_development_dependency "forgery"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.5"
  s.add_development_dependency "rspec-its"
  s.add_development_dependency "solid_assert", "~> 1.0"

  if RUBY_ENGINE == "jruby"
    s.add_development_dependency "activerecord-jdbcmysql-adapter"
    s.add_development_dependency "activerecord-jdbcpostgresql-adapter"
    s.add_development_dependency "activerecord-jdbcsqlite3-adapter"
  else
    s.add_development_dependency "mysql2"
    s.add_development_dependency "pg"
    s.add_development_dependency "sqlite3", "~> 1.4.0"
  end

  s.add_runtime_dependency "activerecord", ">= 5.2", "< 7.1"
  s.add_runtime_dependency "uuidtools"
end
