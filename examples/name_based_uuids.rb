# Name-based UUIDs (version 5) are generated deterministically basing
# on attribute values and namespace.

ENV["DB"] ||= "sqlite3"

require "bundler/setup"
Bundler.require :development

require "activeid"
require_relative "../spec/support/0_logger"
require_relative "../spec/support/1_db_connection"

#### SCHEMA ####

ActiveRecord::Schema.define do
  create_table :works, id: false, force: true do |t|
    t.string :id, limit: 36, primary_key: true
    t.string :author_id, limit: 36, index: true
    t.string :title
    t.timestamps
  end

  create_table :authors, id: false, force: true do |t|
    t.string :id, limit: 36, primary_key: true
    t.string :name
    t.timestamps
  end
end

#### MODELS ####

class Work < ActiveRecord::Base
  include ActiveID::Model
  attribute :id, ActiveID::Type::StringUUID.new
  attribute :author_id, ActiveID::Type::StringUUID.new
  belongs_to :author
  natural_key :author_id, :title
  uuid_namespace "a6908e1e-5493-4c55-a11d-cd8445654de6"
end

class Author < ActiveRecord::Base
  include ActiveID::Model
  attribute :id, ActiveID::Type::StringUUID.new
  has_many :works
  natural_key :name
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

# Natural keys (UUIDs version 5) are generated deterministically.  Hence,
# following will succeed despite that id is hardcoded:
assert Author.find_by(id: "cb23040c-7635-58f2-a703-434c962821c1") == poe

# Above UUID has been generated basing on author's name:
uuid_namespace = UUIDTools::UUID_OID_NAMESPACE
poe_id = UUIDTools::UUID.sha1_create(uuid_namespace, "Edgar Alan Poe")
assert Author.find_by(id: poe_id).name == "Edgar Alan Poe"

# Natural keys can be generated from more than just one field.  Also,
# a namespace can be set for given model:
uuid_namespace = UUIDTools::UUID.parse("a6908e1e-5493-4c55-a11d-cd8445654de6")
raven_id = UUIDTools::UUID.sha1_create(uuid_namespace, "#{poe_id}-The Raven")
assert Work.find_by(id: raven_id).title == "The Raven"

#### PROVE THAT ASSERTIONS WERE WORKING ####

begin
  assert 1 == 2
rescue SolidAssert::AssertionFailedError
  puts "All OK."
else
  raise "Assertions do not work!"
end
