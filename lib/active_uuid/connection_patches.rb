require "active_record"
require "active_support/concern"


module ActiveUUID
  module ConnectionPatches
    module Migrations
      def uuid(*column_names)
        options = column_names.extract_options!
        column_names.each do |name|
          type = ActiveRecord::Base.connection.adapter_name.casecmp("postgresql").zero? ? "uuid" : "binary(16)"
          column(name, "#{type}#{' PRIMARY KEY' if options.delete(:primary_key)}", options)
        end
      end
    end

    module Quoting
      extend ActiveSupport::Concern

      def self.prepended(_klass)
        def native_database_types
          super.merge(uuid: { name: "binary", limit: 16 })
        end
      end
    end

    module PostgreSQLQuoting
      extend ActiveSupport::Concern

      def self.prepended(_klass)
        def native_database_types
          super.merge(uuid: { name: "uuid" })
        end
      end
    end

    module ConnectionHandling
      def establish_connection(_ = nil)
        super

        aca = ActiveRecord::ConnectionAdapters

        aca::Table.send           :include, Migrations if defined? aca::Table
        aca::TableDefinition.send :include, Migrations if defined? aca::TableDefinition

        aca::MysqlAdapter.send      :prepend, Quoting           if defined? aca::MysqlAdapter
        aca::Mysql2Adapter.send     :prepend, Quoting           if defined? aca::Mysql2Adapter
        aca::SQLite3Adapter.send    :prepend, Quoting           if defined? aca::SQLite3Adapter
        aca::PostgreSQLAdapter.send :prepend, PostgreSQLQuoting if defined? aca::PostgreSQLAdapter
      end
    end

    def self.apply!
      ActiveRecord::Base.singleton_class.prepend ConnectionHandling
    end
  end
end

ActiveUUID::ConnectionPatches.apply!
