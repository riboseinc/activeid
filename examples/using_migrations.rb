# Active UUID features a convenience #uuid method, which may be used to create
# a binary column in database migration.  Since it involves monkey patching,
# "active_uuid/all" must be loaded.

ENV["DB"] ||= "sqlite3"

require "bundler/setup"
Bundler.require :development

# Note "active_uuid/all", which registers new column definitions!
require "active_uuid/all"

require_relative "../spec/support/0_logger"
require_relative "../spec/support/1_db_connection"

#### SCHEMA ####

ActiveRecord::Schema.define do
  create_table :authors, id: false, force: true do |t|
    t.uuid :id, primary_key: true
    t.string :name
    t.timestamps
  end
end

#### PROOF ####

SolidAssert.enable_assertions

id_column = ActiveRecord::Base.connection.columns("authors")[0]
assert id_column.name == "id"

case ENV["DB"]
when "sqlite3"
  assert id_column.sql_type == "binary(16)"
when "mysql"
  assert id_column.sql_type == "varbinary(16)"
when "postgresql"
  assert id_column.sql_type == "uuid"
end

#### PROVE THAT ASSERTIONS WERE WORKING ####

begin
  assert 1 == 2
rescue SolidAssert::AssertionFailedError
  puts "All OK."
else
  raise "Assertions do not work!"
end
