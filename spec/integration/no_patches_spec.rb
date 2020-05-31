require "spec_helper"

RSpec.describe "without monkey patches" do
  before do
    unless ENV.fetch("NO_PATCHES", false)
      skip "Monkey patching is enabled in this build"
    end
  end

  it "does not patch ActiveRecord connection" do
    db_conn = ActiveRecord::Base.connection
    db_conn_modules = db_conn.singleton_class.ancestors

    expect(db_conn_modules).to all(satisfy { |m| /ActiveID/ !~ m.name })
  end

  it "does not patch Table class" do
    table_modules = ActiveRecord::ConnectionAdapters::Table.ancestors
    expect(table_modules).to all(satisfy { |m| /ActiveID/ !~ m.name })
  end

  it "does not patch TableDefinition class" do
    table_modules = ActiveRecord::ConnectionAdapters::TableDefinition.ancestors
    expect(table_modules).to all(satisfy { |m| /ActiveID/ !~ m.name })
  end
end
