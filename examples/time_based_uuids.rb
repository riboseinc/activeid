# Time-based UUIDs (version 1) store timestamp of their creation, and are
# monotonically increasing in time.  This is very advantageous in some
# use cases.

ENV["DB"] ||= "sqlite3"

require "bundler/setup"
Bundler.require :development

require "active_uuid"
require_relative "../spec/support/0_logger"
require_relative "../spec/support/1_db_connection"

#### SCHEMA ####

ActiveRecord::Schema.define do
  create_table :authors, id: false, force: true do |t|
    t.string :id, limit: 36, primary_key: true
    t.string :name
    t.timestamps
  end
end

#### MODELS ####

class Author < ActiveRecord::Base
  include ActiveUUID::Model
  attribute :id, ActiveUUID::Type::StringUUID.new
  uuid_generator :time
end

#### PROOF ####

SolidAssert.enable_assertions

poe = Author.create! name: "Edgar Alan Poe"
thu = Author.create! name: "Thucydides"
fon = Author.create! name: "Jean de La Fontaine"
kas = Author.create! name: "Jan Kasprowicz"

# Version 1 means time-based UUIDs
assert poe.id.version == 1

# Timestamp can be extracted from UUID
assert poe.id.timestamp.between? 1.minute.ago, 1.minute.from_now

# Lexicographical ordering of version 1 UUIDs reflects their temporal ordering
assert Author.all.order(id: :asc).to_a == [poe, thu, fon, kas]

#### PROVE THAT ASSERTIONS WERE WORKING ####

begin
  assert 1 == 2
rescue SolidAssert::AssertionFailedError
  puts "All OK."
else
  raise "Assertions do not work!"
end
