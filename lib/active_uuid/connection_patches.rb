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

        aca = ActiveRecord::ConnectionAdapters

        aca::Table.send           :include, ColumnMethods if defined? aca::Table
        aca::TableDefinition.send :include, ColumnMethods if defined? aca::TableDefinition

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
