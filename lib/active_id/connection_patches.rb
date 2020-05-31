require "active_record"
require "active_support/concern"

module ActiveID
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
      def establish_connection(*_args) # rubocop:disable Metrics/MethodLength
        super

        arca = ActiveRecord::ConnectionAdapters

        arca::Table.include(ColumnMethods)
        arca::TableDefinition.include(ColumnMethods)

        if defined? arca::MysqlAdapter
          arca::MysqlAdapter.prepend(Quoting)
        end

        if defined? arca::Mysql2Adapter
          arca::Mysql2Adapter.prepend(Quoting)
        end

        if defined? arca::SQLite3Adapter
          arca::SQLite3Adapter.prepend(Quoting)
        end

        if defined? arca::PostgreSQLAdapter
          arca::PostgreSQLAdapter.prepend(PostgreSQLQuoting)
        end
      end
    end

    def self.apply!
      ActiveRecord::Base.singleton_class.prepend ConnectionHandling
    end
  end
end

ActiveID::ConnectionPatches.apply!
