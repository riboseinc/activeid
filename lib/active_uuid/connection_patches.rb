require "active_record"
require "active_support/concern"


module ActiveUUID
  module ConnectionPatches
    module ColumnMethods
      def uuid(*args, **options)
        args.each { |name| column(name, :uuid, options) }
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

        arca = ActiveRecord::ConnectionAdapters

        arca::Table.send           :include, ColumnMethods if defined? arca::Table
        arca::TableDefinition.send :include, ColumnMethods if defined? arca::TableDefinition

        arca::MysqlAdapter.send      :prepend, Quoting           if defined? arca::MysqlAdapter
        arca::Mysql2Adapter.send     :prepend, Quoting           if defined? arca::Mysql2Adapter
        arca::SQLite3Adapter.send    :prepend, Quoting           if defined? arca::SQLite3Adapter
        arca::PostgreSQLAdapter.send :prepend, PostgreSQLQuoting if defined? arca::PostgreSQLAdapter
      end
    end

    def self.apply!
      ActiveRecord::Base.singleton_class.prepend ConnectionHandling
    end
  end
end

ActiveUUID::ConnectionPatches.apply!
