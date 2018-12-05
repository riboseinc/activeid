require "spec_helper"

describe "migration methods" do
  shared_examples "active record examples" do |can_change_column_to_uuid: true|
    let(:connection) { ActiveRecord::Base.connection }
    let(:table_name) { :test_uuid_field_creation }
    let(:table_columns) { connection.columns(table_name) }
    let(:column) { table_columns.detect { |c| c.name.to_sym == column_name } }

    def table_exists?(table_name)
      connection.respond_to?(:data_source_exists?) ?
        connection.data_source_exists?(table_name) :
        connection.table_exists?(table_name)
    end

    around do |example|
      connection.drop_table(table_name) if table_exists?(table_name)
      connection.create_table(table_name)
      expect(table_exists?(table_name)).to be(true)
      example.run
      connection.drop_table(table_name)
    end

    describe "#add_column" do
      let(:column_name) { :uuid_column }

      def perform
        connection.add_column(table_name, column_name, :uuid)
      end

      it "adds a column of correct SQL type to the table" do
        perform
        expect(connection.column_exists?(table_name, column_name)).to be(true)
        expect(column.sql_type).to eq(sql_type_for_uuid)
      end
    end

    describe "#change_column" do
      let(:column_name) { :string_col }

      before do
        connection.add_column(table_name, column_name, :string)
      end

      def perform
        connection.change_column(table_name, column_name, :uuid)
      end

      if can_change_column_to_uuid
        it "changes column type to a proper one for UUID storage" do
          perform
          expect(column.sql_type).to eq(sql_type_for_uuid)
        end
      else
        it "raises exception when attempting to change the column type " +
          "to one proper for UUID storage" do
          expect { perform }.to raise_exception(ActiveRecord::StatementInvalid)
        end
      end
    end
  end

  context "with SQLite3 backend" do
    before { skip "backend unavailable" unless ENV["DB"] == "sqlite3" }

    let(:sql_type_for_uuid) { "binary(16)" }

    include_examples "active record examples"
  end

  context "with MySQL backend" do
    before { skip "backend unavailable" unless ENV["DB"] == "mysql" }

    let(:sql_type_for_uuid) { "binary(16)" }

    include_examples "active record examples"
  end

  context "with PostgreSQL backend" do
    before { skip "backend unavailable" unless ENV["DB"] == "postgresql" }

    let(:sql_type_for_uuid) { "uuid" }

    include_examples "active record examples", can_change_column_to_uuid: false
  end
end
