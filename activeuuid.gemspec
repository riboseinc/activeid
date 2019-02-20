# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "active_uuid/version"

Gem::Specification.new do |s|
  s.name        = "activeuuid"
  s.version     = Activeuuid::VERSION
  s.authors     = ["Nate Murray"]
  s.email       = ["nate@natemurray.com"]
  s.homepage    = "https://github.com/jashmenn/activeuuid"
  s.summary     = "Add binary UUIDs to ActiveRecord in MySQL"
  s.description = "Add binary (not string) UUIDs to ActiveRecord in MySQL"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activerecord", ">= 5.0", "< 6.0"
  s.add_runtime_dependency "uuidtools"
end
