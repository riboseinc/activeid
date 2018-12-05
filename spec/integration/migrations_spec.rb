require "spec_helper"

describe ActiveRecord::Base do
  context ".connection" do
    def table_exists?(connection, table_name)
      connection.respond_to?(:data_source_exists?) ?
        connection.data_source_exists?(table_name) :
        connection.table_exists?(table_name)
    end

    let!(:connection) { ActiveRecord::Base.connection }
    let(:table_name) { :test_uuid_field_creation }

    before do
      connection.drop_table(table_name) if table_exists?(connection, table_name)
      connection.create_table(table_name)
    end

    after do
      connection.drop_table table_name
    end

    specify { expect(table_exists?(connection, table_name)).to be_truthy }

    context "#add_column" do
      let(:column_name) { :uuid_column }
      let(:column) { connection.columns(table_name).detect { |c| c.name.to_sym == column_name } }

      before { connection.add_column table_name, column_name, :uuid }

      specify { expect(connection.column_exists?(table_name, column_name)).to be_truthy }
      specify { expect(column).not_to be_nil }

      it "should have proper sql type" do
        spec_for_adapter do |adapters|
          adapters.sqlite3 { expect(column.sql_type).to eq("binary(16)") }
          adapters.mysql2 { expect(column.sql_type).to eq("binary(16)") }
          adapters.postgresql { expect(column.sql_type).to eq("uuid") }
        end
      end
    end

    context "#change_column" do
      let(:column_name) { :string_col }
      let(:column) { connection.columns(table_name).detect { |c| c.name.to_sym == column_name } }

      before do
        connection.add_column table_name, column_name, :string
        spec_for_adapter do |adapters|
          adapters.sqlite3 { connection.change_column table_name, column_name, :uuid }
          adapters.mysql2 { connection.change_column table_name, column_name, :uuid }
        end
      end

      it "support changing type from string to uuid" do
        spec_for_adapter do |adapters|
          adapters.sqlite3 { expect(column.sql_type).to eq("binary(16)") }
          adapters.mysql2 { expect(column.sql_type).to eq("binary(16)") }
          adapters.postgresql { skip("postgresql can`t change column type to uuid") }
        end
      end
    end
  end
end
