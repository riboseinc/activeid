# Active UUID types can be added to Active Record's type registry.  This is
# convenient as you can reference them in your models with a symbol.
#
# See Rails API docs for more information about +ActiveRecord::Type.register+:
# https://api.rubyonrails.org/classes/ActiveRecord/Type.html#method-c-register

ENV["DB"] ||= "sqlite3"

require "bundler/setup"
Bundler.require :development

require "active_uuid"
require_relative "../spec/support/0_logger"
require_relative "../spec/support/1_db_connection"

#### SCHEMA ####

ActiveRecord::Schema.define do
  create_table :authors, id: false, force: true do |t|
    if ENV["DB"] == "postgresql"
      t.uuid :id, primary_key: true
    else
      t.binary :id, limit: 16, primary_key: true
    end
    t.string :name
    t.timestamps
  end
end

#### TYPE REGISTRATION ####

ActiveRecord::Type.register(
  :uuid,
  ActiveUUID::Type::BinaryUUID,
)

# In PostgreSQL adapter, +:uuid+ is already registered, but it can be overriden.
ActiveRecord::Type.register(
  :uuid,
  ActiveUUID::Type::StringUUID,
  adapter: :postgresql,
  override: true,
)

#### MODELS ####

class Author < ActiveRecord::Base
  include ActiveUUID::Model
  attribute :id, :uuid
end

#### PROOF ####

SolidAssert.enable_assertions

Author.create! name: "Edgar Alan Poe"

assert Author.count == 1

if ENV["DB"] == "postgresql"
  assert ActiveUUID::Type::StringUUID === Author.first.type_for_attribute("id")
else
  assert ActiveUUID::Type::BinaryUUID === Author.first.type_for_attribute("id")
end

#### PROVE THAT ASSERTIONS WERE WORKING ####

begin
  assert 1 == 2
rescue SolidAssert::AssertionFailedError
  puts "All OK."
else
  raise "Assertions do not work!"
end
