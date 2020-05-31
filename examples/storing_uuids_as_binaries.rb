# See README for comparison between string and binary storage.

ENV["DB"] ||= "sqlite3"

if ENV["DB"] == "postgresql"
  puts <<~MESSAGE
    Example irrelevant for selected database (#{ENV['DB']}).
    Storing UUIDs as binaries is not compatible with PostgreSQL adapter.
  MESSAGE
  exit(0)
end

require "bundler/setup"
Bundler.require :development

require "active_id"
require_relative "../spec/support/0_logger"
require_relative "../spec/support/1_db_connection"

#### SCHEMA ####

ActiveRecord::Schema.define do
  create_table :works, id: false, force: true do |t|
    t.binary :id, limit: 16, primary_key: true
    t.binary :author_id, limit: 16, index: true
    t.string :title
    t.timestamps
  end

  create_table :authors, id: false, force: true do |t|
    t.binary :id, limit: 16, primary_key: true
    t.string :name
    t.timestamps
  end
end

#### MODELS ####

class Work < ActiveRecord::Base
  include ActiveID::Model
  attribute :id, ActiveID::Type::BinaryUUID.new
  attribute :author_id, ActiveID::Type::BinaryUUID.new
  belongs_to :author
end

class Author < ActiveRecord::Base
  include ActiveID::Model
  attribute :id, ActiveID::Type::BinaryUUID.new
  has_many :works
end

#### PROOF ####

SolidAssert.enable_assertions

poe = Author.create! name: "Edgar Alan Poe"
thu = Author.create! name: "Thucydides"

Work.create! title: "The Raven", author: poe
Work.create! title: "The Black Cat", author: poe
Work.create! title: "History of the Peloponnesian War", author: thu

assert Author.count == 2
assert Work.count == 3

assert Author.find_by(name: "Edgar Alan Poe").works.size == 2
assert Author.find_by(name: "Thucydides").works.size == 1

assert UUIDTools::UUID === Author.first.id
assert UUIDTools::UUID === Work.first.id
assert UUIDTools::UUID === Work.first.author_id

# Version 4 means randomly generated UUID
assert Author.first.id.version == 4

# UUIDs are stored in database as 16 bytes long binaries
raw_id = Author.first.attributes_before_type_cast["id"]
assert raw_id.bytes.size == 16

#### PROVE THAT ASSERTIONS WERE WORKING ####

begin
  assert 1 == 2
rescue SolidAssert::AssertionFailedError
  puts "All OK."
else
  raise "Assertions do not work!"
end
